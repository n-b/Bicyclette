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
@property IBOutlet UIImageView *logoView;
@property IBOutlet UIButton *outCloseButton;
@property IBOutlet UIButton *inCloseButton;
@property IBOutlet UIView *legendViewForBikes;
@property IBOutlet UIView *legendViewForParking;
@property IBOutlet UIView *legendViewForStaleData;
@property IBOutlet UIView *legendViewForRadar;
@property IBOutlet UIView *legendViewForRadarHandle;
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
    self.logoView.layer.cornerRadius = 9;

    self.legendViewForBikes.layer.delegate = self;
    self.legendViewForParking.layer.delegate = self;
    self.legendViewForStaleData.layer.delegate = self;
    self.legendViewForRadar.layer.delegate = self;
    self.legendViewForRadarHandle.layer.delegate = self;
    
    self.legendViewForRadarHandle.layer.shadowOpacity = .4f;
    self.legendViewForRadarHandle.layer.shadowOffset = CGSizeMake(0, .5*self.legendViewForRadarHandle.bounds.size.height);
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
    [self.legendViewForRadar.layer setNeedsDisplay];
    [self.legendViewForRadarHandle.layer setNeedsDisplay];

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
                                         phase:0];
    
    if(layer==self.legendViewForParking.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeSolid
                                     baseColor:kGoodValueColor
                                         value:@"7"
                                         phase:0];
    
    if(layer==self.legendViewForStaleData.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:CGSizeMake(kStationAnnotationViewSize, kStationAnnotationViewSize)
                                         scale:scale
                                         shape:BackgroundShapeRoundedRect
                                    borderMode:BorderModeSolid
                                     baseColor:kUnknownValueColor
                                         value:@"32"
                                         phase:0];
    
    if(layer==self.legendViewForRadar.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:self.legendViewForRadar.bounds.size
                                         scale:scale
                                         shape:BackgroundShapeOval
                                    borderMode:BorderModeDashes
                                     baseColor:nil
                                         value:@""
                                         phase:0];
    
    if(layer==self.legendViewForRadarHandle.layer)
        layer.contents =
        (id)[_drawingCache sharedImageWithSize:self.legendViewForRadarHandle.bounds.size
                                         scale:scale
                                         shape:BackgroundShapeOval
                                    borderMode:BorderModeSolid
                                     baseColor:kRadarAnnotationSelectedColor
                                         value:@""
                                         phase:0];
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
    if(self.pageControl.currentPage==self.pageControl.numberOfPages-1)
    {
        self.outCloseButton.enabled = YES;
        [self.contentView bringSubviewToFront:self.inCloseButton];
        self.inCloseButton.enabled = YES;
    }
}

@end
