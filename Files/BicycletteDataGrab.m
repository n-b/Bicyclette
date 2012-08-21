//
//  main.m
//  BicycletteDataGrab
//
//  Created by Nicolas Bouilleaud on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString * path = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Velib.sqlite"];

        // Clear stuff from previous runs
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DebugAlwaysDownloadStationList"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        
        // Create Model
        VelibModel * model = [[VelibModel alloc] initWithModelName:@"VelibModel" storeURL:[NSURL fileURLWithPath:path]];

        // Observe notifications
        [[NSNotificationCenter defaultCenter] addObserverForName:nil object:model queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note)
        {
            // Progress
            // VelibModel itself logs a lot of stuff during parsing regarding heuristics and hardcoded fixes
            if([note.name isEqualToString:VelibModelNotifications.updateBegan])
                printf("updating...\n");
            else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
                printf("parsing...\n");

            // Success
            else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
            {
                BOOL dataChanged = [note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue];
                if(dataChanged)
                {
                    // How many stations were created ?
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
                    NSUInteger count = [model.moc countForFetchRequest:request error:NULL];
                    NSString * message = [NSString stringWithFormat:@"completed. %d stations", (int)count];
                    // Were some 
                    NSArray * saveErrors = note.userInfo[VelibModelNotifications.keys.saveErrors];
                    if(nil!=saveErrors)
                        message = [message stringByAppendingFormat:@"\nerrors:\n%@.",
                                   [[saveErrors valueForKey:@"localizedDescription"] componentsJoinedByString:@"\n"]];
                    
                    printf("%s\n",[message UTF8String]);
                    exit(0);
                }
                else
                {
                    // should not happen, since we cleared data at launch.
                    // This is a build tool, I don't worry too much about concurrent runs.
                    printf("completed with no new data (?)\n");
                    exit(1);
                }
            }
            
            // Failure
            else if([note.name isEqualToString:VelibModelNotifications.updateFailed])
            {
                NSError * error = note.userInfo[VelibModelNotifications.keys.failureError];
                printf("%s\n",[[NSString stringWithFormat:@"failed : %@", [error localizedDescription]] UTF8String]);
                exit(2);
            }
        }];
        
        // Update and run
        [model update];
        [[NSRunLoop currentRunLoop] run];
    }

    // should not happen
    return -1;
}

