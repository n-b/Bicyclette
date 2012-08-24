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
@property (weak) IBOutlet UIView *box;
@property (weak) IBOutlet UIScrollView *scrollView;
@property (weak) IBOutlet UIView *contentView;
@property (weak) IBOutlet UIPageControl *pageControl;
@property (weak) IBOutlet UIImageView *logoView;
@property (weak) IBOutlet UIButton *closeButton;
@property (weak) IBOutlet UIView *legendViewForBikes;
@property (weak) IBOutlet UIView *legendViewForParking;
@property (weak) IBOutlet UIView *legendViewForStaleData;
@property (weak) IBOutlet UIView *legendViewForRadar;
@property (weak) IBOutlet UIView *legendViewForRadarHandle;
@end

/****************************************************************************/
#pragma mark -

@implementation HelpVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.box.layer.cornerRadius = 13;
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.logoView.layer.cornerRadius = 9;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Display fake data
    DrawingCache * drawingCache = [DrawingCache new];
    
    CGFloat scale = self.view.window.screen.scale;
    
    self.legendViewForBikes.layer.contents =
    (id)[drawingCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                                            scale:scale
                                                            shape:BackgroundShapeOval
                                                       borderMode:BorderModeSolid
                                                        baseColor:kGoodValueColor
                                                            value:@"12"
                                                            phase:0];
    
    self.legendViewForParking.layer.contents =
    (id)[drawingCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                                            scale:scale
                                                            shape:BackgroundShapeRoundedRect
                                                       borderMode:BorderModeSolid
                                                        baseColor:kGoodValueColor
                                                            value:@"7"
                                                            phase:0];
    
    self.legendViewForStaleData.layer.contents =
    (id)[drawingCache sharedAnnotationViewBackgroundLayerWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                                            scale:scale
                                                            shape:BackgroundShapeRoundedRect
                                                       borderMode:BorderModeSolid
                                                        baseColor:kUnknownValueColor
                                                            value:@"32"
                                                            phase:0];
    
    self.legendViewForRadar.layer.contents =
    (id)[drawingCache sharedAnnotationViewBackgroundLayerWithSize:self.legendViewForRadar.bounds.size
                                                            scale:scale
                                                            shape:BackgroundShapeOval
                                                       borderMode:BorderModeDashes
                                                        baseColor:nil
                                                            value:@""
                                                            phase:0];
    
    self.legendViewForRadarHandle.layer.contents =
    (id)[drawingCache sharedAnnotationViewBackgroundLayerWithSize:self.legendViewForRadarHandle.bounds.size
                                                            scale:scale
                                                            shape:BackgroundShapeOval
                                                       borderMode:BorderModeSolid
                                                        baseColor:kRadarAnnotationSelectedColor
                                                            value:@""
                                                            phase:0];
    
    self.legendViewForRadarHandle.layer.shadowOpacity = .4f;
    self.legendViewForRadarHandle.layer.shadowOffset = CGSizeMake(0, .5*self.legendViewForRadarHandle.bounds.size.height);
}

/****************************************************************************/
#pragma mark -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = lround(self.scrollView.contentOffset.x/self.scrollView.bounds.size.width);
    [self enableCloseButtonIfNeeded];
}

- (IBAction)changePage:(UIPageControl *)sender
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = self.pageControl.currentPage * self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:offset animated:YES];
    [self enableCloseButtonIfNeeded];
}

- (void) enableCloseButtonIfNeeded
{
    self.closeButton.enabled = self.pageControl.currentPage==self.pageControl.numberOfPages-1;
}

@end
