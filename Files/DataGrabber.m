//
//  main.m
//  BicycletteDataGrab
//
//  Created by Nicolas Bouilleaud on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Update.h"
#import "BicycletteCity+ServiceDescription.h"

static void GrabDataForCity(BicycletteCity* city)
{
    printf("%s: (%f, %f) %.0fm\n",[[city title] UTF8String], [city knownRegion].center.latitude, [city knownRegion].center.longitude, [city knownRegion].radius );

    __block BOOL finished = NO;
    // Observe notifications
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:city queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note)
     {
         BOOL logProgress = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogProgress"];
         BOOL logGeolocationDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogGeolocationDetails"];
         BOOL logRegionsDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogRegionsDetails"];
         BOOL logStationsDetails = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogStationsDetails"];
         BOOL logErrors = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogErrors"];
         BOOL logMissingGeolocErrors = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataGrabberLogMissingGeolocErrors"];
         // Progress
         // BicycletteCity itself logs a lot of stuff during parsing regarding heuristics and hardcoded fixes
         if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
         {
             if(logProgress)
                 printf("Updating...\n");
         }
         else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
         {
             if(logProgress)
                 printf("Parsing...\n");
         }
         
         // Success
         else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
         {
             BOOL dataChanged = [note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue];
             NSCAssert(dataChanged, @"This is a build tool ! There should not be previously existing data !");

             NSMutableString * message = [NSMutableString new];
             if(logProgress)
                 [message appendFormat:@"Completed\n"];
             
             // region stats
             NSFetchRequest * stationsRequest = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
             
             if(logGeolocationDetails)
             {
                 CLRegion * actualRegion = [city regionContainingData];
                 [message appendFormat:@" data region : (%f, %f) %.0fm\n", actualRegion.center.latitude, actualRegion.center.longitude, actualRegion.radius];
             }

             // Log counts
             NSFetchRequest * regionsRequest = [[NSFetchRequest alloc] initWithEntityName:[Region entityName]];
             regionsRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:RegionAttributes.number ascending:YES]];
             if (logRegionsDetails)
             {
                 NSArray * regions = [city.mainContext executeFetchRequest:regionsRequest error:NULL];
                 NSArray * stations = [city.mainContext executeFetchRequest:stationsRequest error:NULL];
                 [message appendFormat:@" %d Stations %@ Bikes, at least %@ Slots\n", (int)[stations count], [stations valueForKeyPath:@"@sum.status_available"], [stations valueForKeyPath:@"@sum.status_total"]];
                 [message appendFormat:@" %d Regions:\n", (int)[regions count]];
             
                 for (Region * region in regions)
                 {
                     [message appendFormat:@"  %@ : %d Stations, (%@-%@, %@-%@)\n",region.number, (int)[region.stations count], region.minLatitude, region.maxLatitude, region.minLongitude, region.maxLongitude];
                     if (logStationsDetails) {
                         for (Station * station in region.stations)
                         {
                             [message appendFormat:@"   \"%@\"->\"%@\"\n",station.name, [city titleForStation:station]];
                         }
                     }
                 }
             }
             
             
             // Errors ?
             if(logErrors)
             {
                 NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
                 if(nil!=saveErrors)
                 {
                     [message appendFormat:@"\nErrors:\n"];
                     [saveErrors enumerateObjectsUsingBlock:^(NSError* error, NSUInteger idx, BOOL *stop) {
                         CLLocation * l = error.userInfo[NSValidationValueErrorKey];
                         if(l.coordinate.latitude!=0 || l.coordinate.longitude!=0 || logMissingGeolocErrors)
                             [message appendFormat:@" %@ : %@ (%.0fm)\n",[error localizedDescription], [error localizedFailureReason],[l distanceFromLocation:city.location]];
                     }];
                 }
             }
             
             printf("%s\n",[message UTF8String]);
             
             finished = YES;
         }
         
         // Failure
         else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed])
         {
             NSError * error = note.userInfo[BicycletteCityNotifications.keys.failureError];
             printf("%s\n",[[NSString stringWithFormat:@"FAILED : %@", error] UTF8String]);
             finished = YES;
         }
     }];
    
    
    [city update];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
    } while (!finished);
    printf("–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n");
}


/****************************************************************************/
#pragma mark -


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString * workingPath = [[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent];
        BicycletteCitySetSaveStationsWithNoIndividualStatonUpdates(NO);
        BicycletteCitySetStoresDirectory(workingPath);
        
        
        NSArray * serviceInfos = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[workingPath stringByAppendingPathComponent:@"BicycletteCities.json"]]
                                                                 options:0 error:NULL];
        NSMutableArray * fullServiceInfos = [NSMutableArray new];

        NSString * cityFilter = [[NSUserDefaults standardUserDefaults] stringForKey:@"DataGrabberCityFilter"];
        for (BicycletteCity* city in [BicycletteCity allCities]) {
            if([[NSUserDefaults standardUserDefaults] stringForKey:@"DataGrabberLogServiceInfo"])
                printf("• %s à %s\n", [city.serviceName UTF8String], [city.cityName UTF8String]);
            if([[NSUserDefaults standardUserDefaults] stringForKey:@"DataGrabberSkipGrabbing"])
                continue;
            if(cityFilter==nil || [city.cityName rangeOfString:cityFilter].location!=NSNotFound)
            {
                [city erase];
                GrabDataForCity(city);
                [fullServiceInfos addObject:[city fullServiceInfo]];
            }
        }
        
        if(![serviceInfos isEqualToArray:fullServiceInfos] && [cityFilter length]==0)
        {
            NSLog(@"SERVICE INFO HAVE CHANGED");
            NSData * data = [NSJSONSerialization dataWithJSONObject:fullServiceInfos
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:NULL];
            NSString * path = [workingPath stringByAppendingPathComponent:@"BicycletteCities.json"];
            [data writeToFile:path atomically:NO];

        }
    }
}

