//
//  GeofencesMonitor.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 22/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "GeofencesMonitor.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"
#import "BicycletteCity.h"

@interface GeofencesMonitor () <CLLocationManagerDelegate>
@end

@interface Geofence () <NSCoding>
@property (nonatomic) BicycletteCity * city;

@property NSString * cityName;
@property NSArray * stationsNumbers;
@property (nonatomic) NSArray * stations;

- (BOOL) isNearFromStation:(Station*)station;
- (void) initializeRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation GeofencesMonitor
{
    NSArray * _fences;
    CLLocationManager * _locationManager;
    UIAlertView * _authorizationAlertView;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMonitoring)
                                                     name:BicycletteCityNotifications.canRequestLocation object:nil];

        // location manager
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return self;
}

- (void) startMonitoring
{
    //Check the monitored regions and the fences match
    for (CLRegion * region in _locationManager.monitoredRegions)
    {
        Geofence* fence = [self.fences firstObjectWithValue:region.identifier forKeyPath:@"region.identifier"];
        if(fence==nil)
        {
            DebugLog(@"delete unexpected monitored region %@",region.identifier);
            [_locationManager stopMonitoringForRegion:region];
        }
    }
    
    for (Geofence * fence in self.fences) {
        CLRegion * monitoredRegion = [_locationManager.monitoredRegions anyObjectWithValue:fence.region.identifier forKeyPath:@"identifier"];
        if(monitoredRegion==nil)
        {
            DebugLog(@"add missing expected monitored region %@",fence.region.identifier);
            [_locationManager startMonitoringForRegion:fence.region];
        }
            
    }
}

/****************************************************************************/
#pragma mark Archiving

- (NSString*) fencesArchivePath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"fences.plist"];
}

- (NSArray*) fences
{
    if(_fences==nil)
        _fences = [NSKeyedUnarchiver unarchiveObjectWithFile:[self fencesArchivePath]];
    return _fences;
}

- (void)setFences:(NSArray *)fences_
{
    _fences = fences_;
    [NSKeyedArchiver archiveRootObject:_fences toFile:[self fencesArchivePath]];
}

/****************************************************************************/
#pragma mark Public methods

- (void) setStarredStations:(NSArray*)starredStations inCity:(BicycletteCity*)city
{
    NSMutableArray * fences = [NSMutableArray new];
    for (Station * station in starredStations)
    {
        __block Geofence * firstFoundFence = nil;
        
        // Find all fences with at least one near station to the current station
        [fences enumerateObjectsUsingBlock:
         ^(Geofence* fence, NSUInteger idx, BOOL *stop) {
             __block BOOL didAddStationToFence = NO;
             didAddStationToFence = [fence isNearFromStation:station];
             if(didAddStationToFence)
             {
                 if(firstFoundFence==nil)
                 {
                     firstFoundFence = fence;
                     firstFoundFence.stations = [firstFoundFence.stations arrayByAddingObject:station];
                 }
                 else
                 {
                     // unite both fences
                     firstFoundFence.stations = [firstFoundFence.stations arrayByAddingObjectsFromArray:fence.stations];
                     fence.stations = @[];
                 }
             }
         }];
        if(!firstFoundFence)
        {
            Geofence * fence = [Geofence new];
            fence.city = city;
            fence.stations = @[station];
            [fences addObject:fence];
        }
    }
    
    // Clear empty fences
    [fences filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Geofence* fence, NSDictionary *bindings) {
        return [fence.stationsNumbers count]!=0;
    }]];
    
    // Set all fences properties
    [fences makeObjectsPerformSelector:@selector(initializeRegion)];
    
    // reuse old objects if they are identical
    NSArray * oldFences = self.fences;
    NSMutableArray * newFences = [NSMutableArray new];
    for (Geofence* oldFence in oldFences)
    {
        if([oldFence.cityName isEqualToString:city.cityName])
        {
            if([fences containsObject:oldFence])
            {
                // reuse the old object instead of using the new fence.
                [newFences addObject:oldFence];
                [fences removeObject:oldFence];
            }
            else
            {
                // STOP MONITORING
                [_locationManager stopMonitoringForRegion:oldFence.region];
            }
        }
        else
        {
            // Fence from another city. Don't touch.
            [newFences addObject:oldFence];
        }
    }
    
    // New ones
    for (Geofence * fence in fences) {
        // START MONITORING
        [_locationManager startMonitoringForRegion:fence.region];
        [newFences addObject:fence];
    }
    
    [self setFences:newFences];

    DebugLog(@"monitored regions : %@",[_locationManager.monitoredRegions valueForKeyPath:@"identifier"]);
    DebugLog(@"monitored fences : %@",[newFences valueForKeyPath:@"region.identifier"]);
}

- (NSArray*) geofencesInCity:(BicycletteCity*)city
{
    NSArray * result = self.fences;
    result = [result filteredArrayWithValue:city.cityName forKeyPath:@"cityName"];
    [result setValue:city forKey:@"city"];
    return result;
}

- (Geofence*)fenceWithIdentifier:(NSString*)identifier
{
    Geofence* fence = [self.fences firstObjectWithValue:identifier forKeyPath:@"region.identifier"];
    if(fence==nil)
        DebugLog(@"no known fence found for identifier %@",identifier);
    return fence;
}

/****************************************************************************/
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DebugLog(@"location manager did fail: %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    DebugLog(@"start monitored regions : %@",[_locationManager.monitoredRegions valueForKeyPath:@"identifier"]);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    DebugLog(@"monitoring for region %@ did fail: %@",region, error);
    Geofence* fence = [self fenceWithIdentifier:region.identifier];
    [self.delegate monitor:self fenceMonitoringFailed:fence withError:error];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    DebugLog(@"did enter region %@",region);
    Geofence* fence = [self fenceWithIdentifier:region.identifier];
    [self.delegate monitor:self fenceWasEntered:fence];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    DebugLog(@"did exit region %@",region);
    Geofence* fence = [self fenceWithIdentifier:region.identifier];
    [self.delegate monitor:self fenceWasExited:fence];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [_authorizationAlertView dismissWithClickedButtonIndex:0 animated:NO];
    _authorizationAlertView = nil;
    if(status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)
    {
        NSString * message = NSLocalizedStringFromTable(@"NSLocationUsageDescription", @"InfoPlist", nil);
        if (status==kCLAuthorizationStatusDenied) {
            message = [message stringByAppendingFormat:@"\n%@",NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_DENIED_MESSAGE", nil)];
        }
        _authorizationAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCALIZATION_ERROR_UNAUTHORIZED_TITLE", nil)
                                                                 message:message
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_authorizationAlertView show];
    }
}

@end


/****************************************************************************/
#pragma mark Geofence struct

@implementation Geofence

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.region = [coder decodeObjectForKey:@"region"];
        self.cityName = [coder decodeObjectForKey:@"cityName"];
        self.stationsNumbers = [coder decodeObjectForKey:@"stationsNumbers"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSAssert(self.region!=nil, nil);
    NSAssert(self.cityName!=nil, nil);
    NSAssert(self.stationsNumbers!=nil, nil);
    [coder encodeObject:self.region forKey:@"region"];
    [coder encodeObject:self.cityName forKey:@"cityName"];
    [coder encodeObject:self.stationsNumbers forKey:@"stationsNumbers"];
}

- (BOOL)isEqual:(Geofence*)other
{
    if ( ! [other isKindOfClass:[self class]])
        return NO;
    if(self == other)
        return YES;
    return [self.region.identifier isEqualToString:other.region.identifier];
}

- (NSUInteger)hash
{
    return [self.region.identifier hash];
}

/****************************************************************************/
#pragma mark City

- (void)setCity:(BicycletteCity *)city
{
    NSAssert(self.cityName==nil || [self.cityName isEqualToString:city.cityName], nil);
    _city = city;
    _cityName = city.cityName;
}

/****************************************************************************/
#pragma mark Region

- (void) initializeRegion
{
    NSAssert(self.region==nil, nil);
    NSAssert(self.city!=nil,nil);
    
    NSString * identifier = [NSString stringWithFormat:@"%@.%@",self.cityName,[self.stationsNumbers componentsJoinedByString:@","]];
    
    CLLocationDegrees latitude = [[@[[self.stations valueForKeyPath:@"@min.latitude"],
                                   [self.stations valueForKeyPath:@"@max.latitude"]] valueForKeyPath:@"@avg.self"] doubleValue];
    CLLocationDegrees longitude = [[@[[self.stations valueForKeyPath:@"@min.longitude"],
                                    [self.stations valueForKeyPath:@"@max.longitude"]] valueForKeyPath:@"@avg.self"] doubleValue];
    
    CLLocation * center = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    __block CLLocationDistance radius = 100;
    [self.stations enumerateObjectsUsingBlock:^(Station* station, NSUInteger idx, BOOL *stop) {
        radius = MAX(radius, [station.location distanceFromLocation:center]);
    }];
    
    radius = radius + 50;
    self.region = [[CLRegion alloc] initCircularRegionWithCenter:center.coordinate radius:radius identifier:identifier];
}

/****************************************************************************/
#pragma mark Stations

- (void)setStations:(NSArray *)stations
{
    NSAssert(self.city!=nil, nil);
    self.stationsNumbers = [stations valueForKeyPath:StationAttributes.number];
}

- (NSArray *)stations
{
    NSAssert(self.city!=nil, nil);
    if([self.stationsNumbers count]==0)
        return @[];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:[Station entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"%K in %@",StationAttributes.number, self.stationsNumbers];
    return [self.city.mainContext executeFetchRequest:request error:NULL];
}

- (BOOL) isNearFromStation:(Station*)station
{
    NSAssert(self.city!=nil, nil);
    __block BOOL near = NO;
    CLLocationDistance radarDistance = [[self.city prefForKey:@"RadarDistance"] doubleValue];
    [self.stations enumerateObjectsUsingBlock:
     ^(Station* stationInFence, NSUInteger idx2, BOOL *stop) {
         CLLocationDistance distance = [stationInFence.location distanceFromLocation:station.location];
         if(distance < radarDistance)
         {
             near = YES;
             *stop = YES;
         }
     }];
    return near;
}

/****************************************************************************/
#pragma mark LocalUpdateGroup

- (NSArray *)pointsToUpdate
{
    return [self stations];
}

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.region.center.latitude longitude:self.region.center.longitude];
}

- (CLLocationDistance) radius
{
    return self.region.radius;
}

/****************************************************************************/
#pragma mark MKOverlay

- (CLLocationCoordinate2D) coordinate
{
    return self.region.center;
}

- (MKMapRect)boundingMapRect
{
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(self.region.center, self.region.radius*2.0, self.region.radius*2.0);
    CLLocationCoordinate2D topLeftCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta/2.0),
                                                                          coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta/2.0));
    
    
    CLLocationCoordinate2D bottomRightCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta/2.0),
                                                                              coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x,
                                      topLeftMapPoint.y,
                                      fabs(bottomRightMapPoint.x-topLeftMapPoint.x),
                                      fabs(bottomRightMapPoint.y-topLeftMapPoint.y));

    return mapRect;
}

@end

