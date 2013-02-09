//
//  UIApplication+LocalAlerts.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "UIApplication+LocalAlerts.h"
#import "BicycletteCity.h"

@implementation UIApplication (LocalAlerts)

- (UILocalNotification*) presentLocalNotificationMessage:(NSString*)message soundName:(NSString*)soundName userInfo:(NSDictionary*)userInfo
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        UILocalNotification * userLocalNotif = [UILocalNotification new];
        userLocalNotif.alertBody = message;
        userLocalNotif.hasAction = NO;
        userLocalNotif.userInfo = userInfo;
        userLocalNotif.soundName = soundName;
        [self presentLocalNotificationNow:userLocalNotif];
        return userLocalNotif;
    }
    else
    {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugDisplayLocalNotificationsAsAlerts"])
        {
            [[[UIAlertView alloc] initWithTitle:@"Notification"
                                        message:message delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        return nil;
    }
}

- (UILocalNotification*) presentLocalNotificationForStationSummary:(Station*)station
{
    return [self presentLocalNotificationMessage:station.localizedSummary
                                       soundName:@"bell.wav"
                                        userInfo:(@{@"city": station.city.cityName ,
                                                  @"stationNumber": station.number})];
}

@end
