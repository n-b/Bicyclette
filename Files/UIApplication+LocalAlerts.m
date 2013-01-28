//
//  UIApplication+LocalAlerts.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIApplication+LocalAlerts.h"

@implementation UIApplication (LocalAlerts)

- (void) presentLocalNotificationMessage:(NSString*)message
{
    [self presentLocalNotificationMessage:message userInfo:nil];
}

- (void) presentLocalNotificationMessage:(NSString*)message userInfo:(NSDictionary*)userInfo
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        UILocalNotification * userLocalNotif = [UILocalNotification new];
        userLocalNotif.alertBody = message;
        userLocalNotif.hasAction = NO;
        userLocalNotif.soundName = UILocalNotificationDefaultSoundName;
        userLocalNotif.userInfo = userInfo;
        userLocalNotif.soundName = @"bell.wav";
        [self presentLocalNotificationNow:userLocalNotif];
    }
    else
    {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugDisplayLocalNotificationsAsAlerts"])
        {
            [[[UIAlertView alloc] initWithTitle:@"Notification"
                                        message:message delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }
}

@end
