//
//  StationDetailVC.h
//  Bicyclette
//
//  Created by Nicolas on 30/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;
@class StationStatusView;
@interface StationDetailVC : UIViewController 

+ (id) detailVCWithStation:(Station*) station inArray:(NSArray*)stations;
- (id) initWithStation:(Station*) station inArray:(NSArray*)stations;

// Action
- (IBAction) switchFavorite;

- (IBAction) changeToPreviousNext;

// Data
@property (nonatomic, strong) Station * station;
@property (nonatomic, strong, readonly) NSArray * stations; // station must be in stations

@end
