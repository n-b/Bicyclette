//
//  UIApplication+LocalAlerts.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@interface UIApplication (LocalAlerts)

- (void) presentLocalNotificationMessage:(NSString*)message;
- (void) presentLocalNotificationMessage:(NSString*)message userInfo:(NSDictionary*)userInfo;

@end
