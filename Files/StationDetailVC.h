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
@property (nonatomic, assign) IBOutlet UIScrollView * scrollView;
@property (nonatomic, assign) IBOutlet UIView * contentView;

@property (nonatomic, assign) IBOutlet UILabel * numberLabel;
@property (nonatomic, assign) IBOutlet UILabel * shortNameLabel;
@property (nonatomic, assign) IBOutlet UILabel * addressLabel;
@property (nonatomic, assign) IBOutlet UILabel * distanceLabel;

@property (nonatomic, assign) IBOutlet StationStatusView * statusView;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, assign) IBOutlet UILabel * statusDateLabel;

@property (nonatomic, assign) IBOutlet UIButton * favoriteButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem * previousNextBarItem; // retained
@property (nonatomic, assign) IBOutlet UISegmentedControl * previousNextControl;

// Action
- (IBAction) switchFavorite;

- (IBAction) changeToPreviousNext;

// Data
@property (nonatomic, retain) Station * station;
@property (nonatomic, retain, readonly) NSArray * stations; // station must be in stations

@end
