//
//  main.m
//  BicycletteDataGrab
//
//  Created by Nicolas Bouilleaud on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCities.h"
#import "BicycletteCity.mogenerated.h"

static void GrabDataForCity(Class cityClass)
{
    NSString * path = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",NSStringFromClass(cityClass)]];
    
    // Clear stuff from previous runs
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DebugAlwaysDownloadStationList"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    // Create Model
    BicycletteCity * city = [[cityClass alloc] initWithModelName:nil storeURL:[NSURL fileURLWithPath:path]];
    
    printf("%s: (%f, %f) %.0fm\n",[NSStringFromClass(cityClass) UTF8String], [city hardcodedLimits].center.latitude, [city hardcodedLimits].center.longitude, [city hardcodedLimits].radius );

    __block BOOL finished = NO;
    // Observe notifications
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:city queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note)
     {
         // Progress
         // BicycletteCity itself logs a lot of stuff during parsing regarding heuristics and hardcoded fixes
         if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
             printf("Updating...\n");
         else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
             printf("Parsing...\n");
         
         // Success
         else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
         {
             BOOL dataChanged = [note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue];
             NSCAssert(dataChanged, @"This is a build tool ! There should not be previously existing data !");

             NSMutableString * message = [@"Completed\n" mutableCopy];
             // How many stations were created ?
             NSFetchRequest *stationsRequest = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
             [message appendFormat:@" %d Stations\n", (int)[city.moc countForFetchRequest:stationsRequest error:NULL]];
             
             // Get Regions
             NSFetchRequest *regionsRequest = [[NSFetchRequest alloc] initWithEntityName:[Region entityName]];
             regionsRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:RegionAttributes.number ascending:YES]];
             [message appendFormat:@" %d Regions:\n", (int)[city.moc countForFetchRequest:regionsRequest error:NULL]];
             
             for (Region * region in [city.moc executeFetchRequest:regionsRequest error:NULL])
             {
                 [message appendFormat:@"  %@ : %d Stations\n",region.number, (int)[region.stations count]];
                 for (Station * station in region.stations)
                 {
                     [message appendFormat:@"   \"%@\"->\"%@\"\n",station.name, [city titleForStation:station]];
                 }
             }
             
             // Were some
             NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
             if(nil!=saveErrors)
             {
                 [message appendFormat:@"\nErrors:"];
                 [saveErrors enumerateObjectsUsingBlock:^(NSError* error, NSUInteger idx, BOOL *stop) {
                     [message appendFormat:@"\n %@ : %@",[error localizedDescription], [error localizedFailureReason]];
                 }];
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
        for (Class cityClass in BicycletteCityClasses()) {
            GrabDataForCity(cityClass);
        }
    }
}

