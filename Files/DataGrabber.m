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
    BicycletteCity * city = [[cityClass alloc] initWithModelName:NSStringFromClass(cityClass) storeURL:[NSURL fileURLWithPath:path]];
    
    __block BOOL finished = NO;
    // Observe notifications
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:city queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note)
     {
         // Progress
         // BicycletteCity itself logs a lot of stuff during parsing regarding heuristics and hardcoded fixes
         if([note.name isEqualToString:BicycletteCityNotifications.updateBegan])
             printf("updating...\n");
         else if([note.name isEqualToString:BicycletteCityNotifications.updateGotNewData])
             printf("parsing...\n");
         
         // Success
         else if([note.name isEqualToString:BicycletteCityNotifications.updateSucceeded])
         {
             BOOL dataChanged = [note.userInfo[BicycletteCityNotifications.keys.dataChanged] boolValue];
             if(dataChanged)
             {
                 NSMutableString * message = [@"completed\n" mutableCopy];
                 // How many stations were created ?
                 NSFetchRequest *stationsRequest = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
                 [message appendFormat:@" %d stations\n", (int)[city.moc countForFetchRequest:stationsRequest error:NULL]];
                 
                 // Get Regions
                 NSFetchRequest *regionsRequest = [[NSFetchRequest alloc] initWithEntityName:[Region entityName]];
                 regionsRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:RegionAttributes.number ascending:YES]];
                 [message appendFormat:@" %d regions:\n", (int)[city.moc countForFetchRequest:regionsRequest error:NULL]];
                 
                 for (Region * region in [city.moc executeFetchRequest:regionsRequest error:NULL])
                 {
                     [message appendFormat:@"  %@ : %d stations\n",region.number, (int)[region.stations count]];
                 }
                 
                 // Were some
                 NSArray * saveErrors = note.userInfo[BicycletteCityNotifications.keys.saveErrors];
                 if(nil!=saveErrors)
                     [message appendFormat:@"\nerrors:\n%@.",
                      [[saveErrors valueForKey:@"localizedDescription"] componentsJoinedByString:@"\n"]];
                 
                 printf("%s\n",[message UTF8String]);
             }
             else
             {
                 // should not happen, since we cleared data at launch.
                 // This is a build tool, I don't worry too much about concurrent runs.
                 printf("completed with no new data (?)\n");
             }
             finished = YES;
         }
         
         // Failure
         else if([note.name isEqualToString:BicycletteCityNotifications.updateFailed])
         {
             NSError * error = note.userInfo[BicycletteCityNotifications.keys.failureError];
             printf("%s\n",[[NSString stringWithFormat:@"failed : %@", error] UTF8String]);
             finished = YES;
         }
     }];
    
    
    [city update];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
    } while (!finished);
}


/****************************************************************************/
#pragma mark -


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        for (Class cityClass in BicycletteCityClasses()) {
            printf("%s:\n",[NSStringFromClass(cityClass) UTF8String]);
            GrabDataForCity(cityClass);
            printf("–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n");
        }
    }
}

