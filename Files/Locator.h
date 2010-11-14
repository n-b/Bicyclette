//
//  Locator.h
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Locator : NSObject 
- (void) start;
@end

#define LocationDidChangeNotification @"LocationDidChangeNotification"