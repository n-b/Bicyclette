//
//  HelpVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 23/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "HelpVC.h"
#import "DrawingCache.h"

@interface HelpVC () <UIScrollViewDelegate>
@property IBOutlet UIView *box;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UIView *contentView;
@property IBOutlet UIPageControl *pageControl;
@property IBOutlet UIImageView *logoView1;
@property IBOutlet UIImageView *logoView2;
@property IBOutlet UIButton *outCloseButton;
@property IBOutlet UIButton *inCloseButton;
@property IBOutlet UIView *legendViewForBikes;
@property IBOutlet UIView *legendViewForParking;
@property IBOutlet UIView *legendViewForStaleData;
@property IBOutlet UIView *legendViewForGeofence;
@property IBOutlet UIView *legendViewForStarredStation1;
@property IBOutlet UIView *legendViewForStarredStation2;
@property IBOutlet UIView *legendViewForStarredStation3;

@property IBOutlet UIView * notificationView;
@property IBOutlet UIImageView * notificationIconView;


@property IBOutlet UILabel * titleLabel;
@property IBOutlet UILabel * forewordLabel;
@property IBOutlet UILabel * bicycletteDisplaysLabel;
@property IBOutlet UILabel * bikesLabel;
@property IBOutlet UILabel * parkingLabel;
@property IBOutlet UILabel * staleLabel;

@property IBOutlet UILabel * starredStationsLabel;
@property IBOutlet UILabel * geofencesLabel;

@property IBOutlet UILabel * notificationBehaviourLabel;
@property IBOutlet UILabel * notificationTitleLabel;
@property IBOutlet UILabel * notificationDetailLabel;

@property IBOutlet UILabel * pleaseHelpLabel;
@property IBOutlet UILabel * payWhatYouWantLabel;
@property IBOutlet UILabel * epilogueLabel;
@end

/****************************************************************************/
#pragma mark -

@implementation HelpVC
{
    DrawingCache * _drawingCache;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _drawingCache = [DrawingCache new];
    self.box.layer.cornerRadius = 13;
    self.box.layer.shadowOpacity = 1;
    self.box.layer.shadowOffset = CGSizeMake(0, 1);
    self.box.layer.shadowRadius = 2;
    self.box.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;

    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.logoView1.layer.cornerRadius = 9;
    self.logoView2.layer.cornerRadius = 9;

    self.legendViewForBikes.layer.delegate = self;
    self.legendViewForParking.layer.delegate = self;
    self.legendViewForStaleData.layer.delegate = self;

    self.legendViewForGeofence.layer.delegate = self;
    self.legendViewForStarredStation1.layer.delegate = self;
    self.legendViewForStarredStation2.layer.delegate = self;
    self.legendViewForStarredStation3.layer.delegate = self;
    
    self.notificationView.layer.cornerRadius = 10;
    self.notificationView.layer.borderColor = [UIColor blackColor].CGColor;
    self.notificationView.layer.shadowOpacity = 1;
    self.notificationView.layer.shadowOffset = CGSizeMake(0, 3);
    self.notificationView.layer.shadowRadius = 4;
    self.notificationView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.notificationView.layer.borderWidth = 1;
    
    self.notificationIconView.layer.cornerRadius = 4;
    
    self.titleLabel.text = NSLocalizedStringFromTable(@"HELP_TITLE", @"Help", nil);
    self.forewordLabel.text = NSLocalizedStringFromTable(@"HELP_FOREWORD", @"Help", nil);

    self.bicycletteDisplaysLabel.text = NSLocalizedStringFromTable(@"HELP_BICYCLETTE_DISPLAYS", @"Help", nil);
    self.bikesLabel.text = NSLocalizedStringFromTable(@"HELP_BIKES", @"Help", nil);
    self.parkingLabel.text = NSLocalizedStringFromTable(@"HELP_PARKING", @"Help", nil);
    self.staleLabel.text = NSLocalizedStringFromTable(@"HELP_STALE", @"Help", nil);

    self.starredStationsLabel.text = NSLocalizedStringFromTable(@"HELP_STARRED_STATIONS", @"Help", nil);
    self.geofencesLabel.text = NSLocalizedStringFromTable(@"HELP_GEOFENCES", @"Help", nil);

    self.notificationBehaviourLabel.text = NSLocalizedStringFromTable(@"HELP_NOTIFICATIONS_BEHAVIOUR", @"Help", nil);
    self.notificationDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"STATION_%@_STATUS_SUMMARY_BIKES_%d_PARKING_%d", nil),
                                         @"Notre Dame",
                                         10, 13];

    self.pleaseHelpLabel.text = NSLocalizedStringFromTable(@"HELP_PLEASE_HELP", @"Help", nil);
    self.payWhatYouWantLabel.text = NSLocalizedStringFromTable(@"HELP_PAY_WHAT_YOU_WANT", @"Help", nil);
    self.epilogueLabel.text = NSLocalizedStringFromTable(@"HELP_EPILOGUE", @"Help", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // reset
    self.scrollView.contentOffset = CGPointZero;
    self.pageControl.currentPage = 0;
    
    [self.legendViewForBikes.layer setNeedsDisplay];
    [self.legendViewForParking.layer setNeedsDisplay];
    [self.legendViewForStaleData.layer setNeedsDisplay];
    [self.legendViewForGeofence.layer setNeedsDisplay];
    [self.legendViewForStarredStation1.layer setNeedsDisplay];
    [self.legendViewForStarredStation2.layer setNeedsDisplay];
    [self.legendViewForStarredStation3.layer setNeedsDisplay];
}

// Display fake data
- (void)displayLayer:(CALayer *)layer
{
    CGFloat scale = self.view.window.screen.scale;

    if(layer==self.legendViewForBikes.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeOval
                                    borderMode:BorderModeSolid
                                     baseColor:kGoodValueColor
                                         value:@"12"
                                     textColor:kAnnotationValueTextColor
                                         phase:0];
    
    if(layer==self.legendViewForParking.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeSolid
                                     baseColor:kGoodValueColor
                                         value:@"7"
                                     textColor:kAnnotationValueTextColor
                                         phase:0];
    
    if(layer==self.legendViewForStaleData.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeSolid
                                     baseColor:kUnknownValueColor
                                         value:@"32"
                                     textColor:kAnnotationValueTextColorAlt
                                         phase:0];
    
    if(layer==self.legendViewForGeofence.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:self.legendViewForGeofence.bounds.size
                                         scale:scale
                                         shape:BackgroundShapeOval
                                    borderMode:BorderModeDashes
                                     baseColor:kFenceBackgroundColor
                                         value:nil
                                     textColor:nil
                                         phase:0];

    if(layer==self.legendViewForStarredStation1.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeDashes
                                     baseColor:kCriticalValueColor
                                         value:@"0"
                                     textColor:kAnnotationValueTextColor
                                         phase:0];

    if(layer==self.legendViewForStarredStation2.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeDashes
                                     baseColor:kWarningValueColor
                                         value:@"2"
                                     textColor:kAnnotationValueTextColor
                                         phase:0];
    if(layer==self.legendViewForStarredStation3.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeDashes
                                     baseColor:kGoodValueColor
                                         value:@"6"
                                     textColor:kAnnotationValueTextColor
                                         phase:0];
}


/****************************************************************************/
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = lround(self.scrollView.contentOffset.x/self.scrollView.bounds.size.width);
}

- (IBAction)changePage:(UIPageControl *)sender
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = self.pageControl.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:offset animated:YES];
}

/****************************************************************************/
#pragma mark -

- (IBAction)advanceHelp:(id)sender
{
    if(self.pageControl.currentPage == self.pageControl.numberOfPages-1)
    {
        [self.delegate helpFinished:self];
    }
    else
    {
        self.pageControl.currentPage ++;
        [self changePage:self.pageControl];
    }
}

@end
