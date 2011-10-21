//
//  StationStatusView.h
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;

@interface StationStatusView : UIView 
// Data
@property (nonatomic, strong) Station* station;

// Configuration
@property BOOL displayOtherSpots;
@end
