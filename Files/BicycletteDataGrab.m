//
//  main.m
//  BicycletteDataGrab
//
//  Created by Nicolas Bouilleaud on 21/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"

void printline(NSString* msg);
void printline(NSString* msg)
{
    printf("%s\n",[msg UTF8String]);
}

@interface BicycletteDataGrab : NSObject

@end

@implementation BicycletteDataGrab
{
    VelibModel * _model;
}

- (void) grab
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DebugAlwaysDownloadStationList"];
    
    NSString * path = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Velib.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    NSURL * storeURL = [NSURL fileURLWithPath:path];
    _model = [[VelibModel alloc] initWithModelName:@"VelibModel" storeURL:storeURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:nil object:_model];
    [_model update];
}

- (void) modelUpdated:(NSNotification*)note
{
    if([note.name isEqualToString:VelibModelNotifications.updateBegan])
        printline(@"updating...");
    else if([note.name isEqualToString:VelibModelNotifications.updateGotNewData])
        printline(@"parsing...");
    else if([note.name isEqualToString:VelibModelNotifications.updateSucceeded])
    {
        BOOL dataChanged = [note.userInfo[VelibModelNotifications.keys.dataChanged] boolValue];
        if(dataChanged)
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Station entityName]];
            NSUInteger count = [_model.moc countForFetchRequest:request error:NULL];
            NSString * message = [NSString stringWithFormat:@"completed. %d stations", (int)count];
            NSArray * saveErrors = note.userInfo[VelibModelNotifications.keys.saveErrors];
            if(nil!=saveErrors)
                message = [message stringByAppendingFormat:@"\nerrors:\n%@.",
                           [[saveErrors valueForKey:@"localizedDescription"] componentsJoinedByString:@"\n"]];

            printline(message);
            exit(0);
        }
        else
        {
            printline(@"completed with no new data (?)");
            exit(1);
        }
    }
    else if([note.name isEqualToString:VelibModelNotifications.updateFailed])
    {
        NSError * error = note.userInfo[VelibModelNotifications.keys.failureError];
        printline([NSString stringWithFormat:@"failed : %@", [error localizedDescription]]);
        exit(2);
    }
}

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        BicycletteDataGrab * grabber = [BicycletteDataGrab new];
        [grabber grab];
        [[NSRunLoop currentRunLoop] run];
    }
    return -1;
}

