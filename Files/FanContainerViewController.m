//
//  FanContainerViewController.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 03/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FanContainerViewController.h"

@interface FanContainerViewController ()
@property UIViewController * visibleViewController;
@end

@implementation FanContainerViewController

- (void) viewDidLoad
{
    [self setupFront];
    [self setupBack];
    [self setupRotationCenter];
}

- (void) setFrontViewController:(UIViewController *)frontViewController_
{
    [self.frontViewController willMoveToParentViewController:nil];
    [self.frontViewController.view removeFromSuperview];
    [self.frontViewController removeFromParentViewController];

    _frontViewController = frontViewController_;
    
    if([self isViewLoaded])
        [self setupFront];
}

- (void) setupFront
{
    [self addChildViewController:self.frontViewController];
    self.frontViewController.view.frame = self.view.bounds;
    if(self.backViewController)
        [self.view insertSubview:self.frontViewController.view aboveSubview:self.backViewController.view];
    else
    {
        [self.view addSubview:self.backViewController.view];
        [self.view sendSubviewToBack:self.backViewController.view];
    }
    
    [self.frontViewController didMoveToParentViewController:self];
    
    self.frontViewController.view.layer.shadowOffset = CGSizeZero;
    self.frontViewController.view.layer.shadowOpacity = 1;
    [self setFrontViewControllerShadowPath];
    self.visibleViewController = self.frontViewController;
}

- (void) setBackViewController:(UIViewController *)backViewController_
{
    [self.backViewController willMoveToParentViewController:nil];
    [self.backViewController.view removeFromSuperview];
    [self.backViewController removeFromParentViewController];

    _backViewController = backViewController_;

    if([self isViewLoaded])
        [self setupBack];
}

- (void) setupBack
{
    [self addChildViewController:self.backViewController];
    self.backViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.backViewController.view];
    [self.view sendSubviewToBack:self.backViewController.view];
    [self.backViewController didMoveToParentViewController:self];
}

/****************************************************************************/
#pragma mark -

-(CGPoint) rotationCenter
{
    return CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [[self visibleViewController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL) shouldAutorotate
{
    return [[self visibleViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self visibleViewController] supportedInterfaceOrientations];
}

- (void) setupRotationCenter
{
    self.frontViewController.view.layer.anchorPoint = CGPointMake(self.rotationCenter.x/self.view.bounds.size.width,
                                                    self.rotationCenter.y/self.view.bounds.size.height);
    self.frontViewController.view.layer.position = self.rotationCenter;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setFrontViewControllerShadowPath];
    [self setupRotationCenter];
}

- (void) setFrontViewControllerShadowPath
{
    self.frontViewController.view.layer.shadowPath = (__bridge CGPathRef)(CFBridgingRelease(CGPathCreateWithRect(self.frontViewController.view.layer.bounds, NULL)));
}

/****************************************************************************/
#pragma mark -

- (void)switchVisibleViewController
{
    if(self.visibleViewController==self.frontViewController)
        [self showBackViewController];
    else
        [self showFrontViewController];
}

- (void) showBackViewController
{
    self.visibleViewController = self.backViewController;
    
    CGFloat fromAngle = 0;
    CGFloat toAngle = .9*M_PI;
    
    [self animateMapsVCFromAngle:fromAngle toAngle:toAngle];
}

- (void) showFrontViewController
{
    self.visibleViewController = self.frontViewController;
    
    CGFloat fromAngle = .9*M_PI;
    CGFloat toAngle = 0;
    
    [self animateMapsVCFromAngle:fromAngle toAngle:toAngle];
}

- (void) animateMapsVCFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle
{
    CGFloat totalDuration = .5f;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    id presentationValue = [self.frontViewController.view.layer.presentationLayer valueForKey:@"transform"];
    id modelValue = [self.frontViewController.view.layer.modelLayer valueForKey:@"transform"];
    
    CATransform3D presentationTransform = [presentationValue CATransform3DValue];
    CGFloat currentAngle = atan2f(presentationTransform.m12, presentationTransform.m11);
    
    animation.fromValue = presentationValue;
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate([modelValue CATransform3DValue], toAngle, 0, 0, 1)];
    animation.duration = totalDuration*((toAngle-currentAngle)/(toAngle-fromAngle));
    
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    [self.frontViewController.view.layer addAnimation:animation forKey:@"rotation"];
}


@end
