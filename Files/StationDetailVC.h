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

// Outlets
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UIView * contentView;

@property (nonatomic, weak) IBOutlet UILabel * shortNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * addressLabel;
@property (nonatomic, weak) IBOutlet UILabel * distanceLabel;

@property (nonatomic, weak) IBOutlet UILabel * availableCountLabel;
@property (nonatomic, weak) IBOutlet UILabel * freeCountLabel;

@property (nonatomic, weak) IBOutlet StationStatusView * statusView;
@property (nonatomic, weak) IBOutlet UIView * loadingIndicator;

@property (nonatomic, weak) IBOutlet UIButton * favoriteButton;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * previousNextBarItem; // retained
@property (nonatomic, weak) IBOutlet UISegmentedControl * previousNextControl;

// Action
- (IBAction) switchFavorite;

- (IBAction) changeToPreviousNext;

// Data
@property (nonatomic, strong) Station * station;
@property (nonatomic, strong, readonly) NSArray * stations; // station must be in stations

@end
