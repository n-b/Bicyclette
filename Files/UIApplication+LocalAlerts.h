//
//  UIApplication+LocalAlerts.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Station;

@interface UIApplication (LocalAlerts)

- (UILocalNotification*) presentLocalNotificationMessage:(NSString*)message soundName:(NSString*)soundName userInfo:(NSDictionary*)userInfo;

- (UILocalNotification*) presentLocalNotificationForStationSummary:(Station*)station;

@end
