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

- (UILocalNotification*) presentLocalNotificationMessage:(NSString*)message
                                             alertAction:(NSString*)alertAction
                                               soundName:(NSString*)soundName
                                                userInfo:(NSDictionary*)userInfo
                                                fireDate:(NSDate*)fireDate
{
    UILocalNotification * userLocalNotif = [UILocalNotification new];
    userLocalNotif.alertBody = message;
    userLocalNotif.hasAction = YES;
    userLocalNotif.alertAction = alertAction;
    userLocalNotif.userInfo = userInfo;
    userLocalNotif.soundName = soundName;
    if(fireDate) {
        userLocalNotif.fireDate = fireDate;
        [self scheduleLocalNotification:userLocalNotif];
    } else {
        [self presentLocalNotificationNow:userLocalNotif];
    }
    return userLocalNotif;
}

- (UILocalNotification*) presentLocalNotificationForStationSummary:(Station*)station
{
    return [self presentLocalNotificationMessage:station.localizedSummary
                                     alertAction:nil
                                       soundName:@"bell.wav"
                                        userInfo:(@{@"type": @"stationsummary",
                                                  @"city": station.city.cityName ,
                                                  @"stationNumber": station.number})
                                        fireDate:nil];
}

@end
