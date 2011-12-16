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

+ (id) detailVCWithStation:(Station*) station inOrderedSet:(NSOrderedSet*)stations;
- (id) initWithStation:(Station*) station inOrderedSet:(NSOrderedSet*)stations;

// Action
- (IBAction) switchFavorite;

- (IBAction) changeToPreviousNext;

// Data
@property (nonatomic, strong) Station * station;
@property (nonatomic, strong, readonly) NSOrderedSet * stations; // station must be in stations

@end
