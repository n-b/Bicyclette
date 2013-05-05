//
//  BicycletteCity+Update.m
//  Bicyclette
//
//  Created by Nicolas on 12/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Update.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSError+MultipleErrorsCombined.h"
#import "_StationParse.h"

@implementation BicycletteCity (Update)

#pragma mark Data Updates

- (NSArray *) updateURLStrings { return @[self.serviceInfo[@"update_url"]]; }
- (NSString *) detailsURLStringForStation:(Station*)station { return [self.serviceInfo[@"station_details_url"] stringByAppendingString:station.number]; }

- (NSDictionary*) KVCMapping
{
    return self.serviceInfo[@"KVCMapping"];
}

- (Class) stationStatusParsingClass
{
    return nil;
}

- (BOOL) canUpdateIndividualStations
{
    return [self stationStatusParsingClass] != nil;
}

- (BOOL) canShowFreeSlots
{
    return ([[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_free] length]!=0
            || [[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_total] length]!=0);
}

- (void) updateWithCompletionBlock:(void (^)(NSError *))completion_
{
    if(self.updater==nil)
    {
        self.updater = [[DataUpdater alloc] initWithURLStrings:[self updateURLStrings] delegate:self];
        _updateCompletionBlock = [completion_ copy];
        [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:BicycletteCityNotifications.updateBegan object:self]
                                                   postingStyle:NSPostASAP];
    }
    else if(completion_)
            completion_(nil);
}

- (void) update
{
    [self updateWithCompletionBlock:nil];
}

- (void) updater:(DataUpdater *)updater didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateFailed object:self userInfo:@{BicycletteCityNotifications.keys.failureError : error}];
    if(_updateCompletionBlock)
        _updateCompletionBlock(error);
    _updateCompletionBlock = nil;
    self.updater = nil;
}

- (void) updaterDidFinishWithNoNewData:(DataUpdater *)updater
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self userInfo:@{BicycletteCityNotifications.keys.dataChanged : @(NO)}];
    if(_updateCompletionBlock)
        _updateCompletionBlock(nil);
    _updateCompletionBlock = nil;
    self.updater = nil;
}

- (void) updater:(DataUpdater*)updater finishedWithNewDataChunks:(NSDictionary*)datas
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateGotNewData object:self];
    
    __block NSError * validationErrors;
    [self performUpdates:^(NSManagedObjectContext *updateContext) {
        // Get Old Stations Names
        NSError * requestError = nil;
        
        NSFetchRequest * oldStationsRequest = [NSFetchRequest fetchRequestWithEntityName:[Station entityName]];
        oldStationsRequest.returnsObjectsAsFaults = NO;
        NSArray * stations = [updateContext executeFetchRequest:oldStationsRequest error:&requestError];
        NSMutableDictionary* oldStations = [NSMutableDictionary new];
        for (Station * station in stations) {
            oldStations[station.number] = station;
        }
        
        _parsing_context = updateContext;
        _parsing_oldStations = oldStations;
        _parsing_regionsByNumber = [NSMutableDictionary new];
        
        // Parsing
        for (NSString * urlString in datas) {
            _parsing_urlString = urlString;
            [self parseData:datas[urlString]];
            _parsing_urlString = nil;
        }
        _parsing_context = nil;
        _parsing_oldStations = nil;
        _parsing_regionsByNumber = nil;
        
        // Post processing :
        // Validate all stations (and delete invalid) before computing coordinates
        NSFetchRequest * allRegionsRequest = [NSFetchRequest fetchRequestWithEntityName:[Region entityName]];
        NSArray * regions = [updateContext executeFetchRequest:allRegionsRequest error:&requestError];
        for (Region *r in regions) {
            for (Station *s in [r.stations copy]) {
                if(![s validateForInsert:&validationErrors])
                {
                    s.region = nil;
                    [updateContext deleteObject:s];
                }
            }
            [r setupCoordinates];
        }
        
        // Delete Old Stations
        for (Station * oldStation in [oldStations allValues]) {
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                DebugLog(@"Note : old station deleted after update : %@", oldStation);
            [updateContext deleteObject:oldStation];
        }
        
    } saveCompletion:^(NSNotification *contextDidSaveNotification) {
        NSMutableDictionary * userInfo = [@{BicycletteCityNotifications.keys.dataChanged : @(YES)} mutableCopy];
        if (validationErrors)
            userInfo[BicycletteCityNotifications.keys.saveErrors] = [validationErrors underlyingErrors];
        [[NSNotificationCenter defaultCenter] postNotificationName:BicycletteCityNotifications.updateSucceeded object:self
                                                          userInfo:userInfo];
        if(_updateCompletionBlock)
            _updateCompletionBlock(nil);
        _updateCompletionBlock = nil;
    }];
    self.updater = nil;
}

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    NSString * keyForNumber = [[self KVCMapping] wantedKeyForRealKey:StationAttributes.number]; // There *must* be a key mapping to "number" in the KVCMapping dictionary.
    return values[keyForNumber];
}

- (void) setStation:(Station*)station attributes:(NSDictionary*)stationAttributes
{
    BOOL logParsingDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"];
    
    //
    // Set Values
    [station setValuesForKeysWithDictionary:stationAttributes withMappingDictionary:[self KVCMapping]]; // Yay!
    
    //
    // Set patches
    NSDictionary * patchs = [self patches][station.number];
    BOOL hasDataPatches = patchs && ![[[patchs allKeys] arrayByRemovingObjectsInArray:[[self KVCMapping] allKeys]] isEqualToArray:[patchs allKeys]];
    if(hasDataPatches)
    {
        if(logParsingDetails)
            DebugLog(@"Note : Used hardcoded fixes %@. Fixes : %@.",stationAttributes, patchs);
        [station setValuesForKeysWithDictionary:patchs withMappingDictionary:[self KVCMapping]]; // Yay! again
    }
    
    //
    // Build missing status, if needed
    NSString * keyForStatusAvailable = [[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_available];
    NSAssert([keyForStatusAvailable length]!=0, nil);
    if([[stationAttributes allKeys] containsObject:keyForStatusAvailable])
    {
        if([[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_total] length]==0
           && [[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_free] length]!=0)
        {
            // "Total" is not in data but "Free" is
            station.status_totalValue = station.status_freeValue + station.status_availableValue;
        }
        else if ([[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_free] length]==0
                 && [[[self KVCMapping] wantedKeyForRealKey:StationAttributes.status_total] length]!=0)
        {
            // "Free" is not in data but "Total" is
            station.status_freeValue = station.status_totalValue - station.status_availableValue;
        }
        
        // Set Date to now
        station.status_date = [NSDate date];
    }
}

- (void) insertStationWithAttributes:(NSDictionary*)stationAttributes
{
    NSString * stationNumber = [self stationNumberFromStationValues:stationAttributes];
    
    BOOL logParsingDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"];
    
    //
    // Find Existing Station
    Station * station = _parsing_oldStations[stationNumber];
    if(station)
    {
        // found existing
        [_parsing_oldStations removeObjectForKey:stationNumber];
    }
    else
    {
        if(_parsing_oldStations.count && [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
            DebugLog(@"Note : new station found after update : %@", stationAttributes);
        station = [Station insertInManagedObjectContext:_parsing_context];
    }
    
    // Do it !
    [self setStation:station attributes:stationAttributes];
    
    //
    // Set Region
    RegionInfo * regionInfo;
    if([self hasRegions])
    {
        NSDictionary * patchs = [self patches][station.number];
        regionInfo = [self regionInfoFromStation:station values:stationAttributes patchs:patchs requestURL:_parsing_urlString];
        if(nil==regionInfo)
        {
            if(logParsingDetails)
                DebugLog(@"Invalid data : %@",stationAttributes);
            [_parsing_context deleteObject:station];
            return;
        }
    }
    else
    {
        regionInfo = [RegionInfo new];
        regionInfo.number = @"anonymousregion";
        regionInfo.name = @"anonymousregion";
    }
    
    Region * region = _parsing_regionsByNumber[regionInfo.number];
    if(nil==region)
    {
        region = [[Region fetchRegionWithNumber:_parsing_context number:regionInfo.number] lastObject];
        if(region==nil)
        {
            region = [Region insertInManagedObjectContext:_parsing_context];
            region.number = regionInfo.number;
        }
        _parsing_regionsByNumber[regionInfo.number] = region;
    }
    region.name = regionInfo.name;
    station.region = region;
}

@end

/****************************************************************************/
#pragma mark -

@implementation RegionInfo
+ (instancetype) infoWithName:(NSString*)name_ number:(NSString*)number_
{
    RegionInfo * info = [self new];
    info.name = name_;
    info.number = number_;
    return info;
}
@end
