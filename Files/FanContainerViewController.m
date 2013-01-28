//
//  FanContainerViewController.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 03/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FanContainerViewController.h"

#define kFanOpenAngle .9*M_PI
#define kFanAnimationDuration .4f

@interface FanContainerViewController ()
@property UIViewController * visibleViewController;
@end

/****************************************************************************/
#pragma mark -

@implementation FanContainerViewController

/****************************************************************************/
#pragma mark Child View Controllers

- (void) setFrontViewController:(UIViewController *)frontViewController_
{
    [self.frontViewController willMoveToParentViewController:nil];
    [self.frontViewController.view removeFromSuperview];
    [self.frontViewController removeFromParentViewController];

    _frontViewController = frontViewController_;
    
    if([self isViewLoaded])
        [self setupFront];
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
    
    // Add Shadow
    self.frontViewController.view.layer.shadowOffset = CGSizeZero;
    self.frontViewController.view.layer.shadowOpacity = 1;
    [self setupFrontLayerShadowPath];
    self.visibleViewController = self.frontViewController;
}

- (void) setupBack
{
    [self addChildViewController:self.backViewController];
    self.backViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.backViewController.view];
    [self.view sendSubviewToBack:self.backViewController.view];
    [self.backViewController didMoveToParentViewController:self];
}

- (void) setupFrontLayerShadowPath
{
    self.frontViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.frontViewController.view.layer.bounds].CGPath;
}

- (void) setupRotationCenter
{
    // The front view controller layer is actually anchored in the rotation center,
    // and translated back (via its position) so that its bounds fill its frame.
    //
    // This is essential for the rotation animation to take place around that point.
    self.frontViewController.view.layer.anchorPoint = CGPointMake(self.rotationCenter.x/self.view.bounds.size.width,
                                                                  self.rotationCenter.y/self.view.bounds.size.height);
    self.frontViewController.view.layer.position = self.rotationCenter;
}

- (CGPoint) rotationCenter // Reimplemented
{
    return CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setupFront];
    [self setupBack];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do this late : if launched in landscape on iPad, willAnimateRotationToInterfaceOrientation: is not called and the setup is done for portrait in viewDidLoad. 
    [self setupRotationCenter];
    [self setupFrontLayerShadowPath];
}

/****************************************************************************/
#pragma mark Rotation support

- (BOOL) shouldAutorotate
{
    return [[self visibleViewController] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return [[self visibleViewController] supportedInterfaceOrientations];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Our frontVC's shadow must be reset
    [self setupFrontLayerShadowPath];

    // ... with animation
    CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowAnimation.fromValue = (__bridge id)[self.frontViewController.view.layer.presentationLayer shadowPath];
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shadowAnimation.duration = duration;
    [self.frontViewController.view.layer addAnimation:shadowAnimation forKey:@"shadowPath"];

    // When the view rotates, its frame is autoresized (via autoresizing masks),
    // and the bounds+position of the layer is automatically animated
    //
    // However, since the rotation center may not be the same in landscape and portrait,
    // we need to recompute the anchorPoint+position of the frontVC's view.
    [self setupRotationCenter];
    
    // The position is animated for free by UIViewController, but the anchorPoint isn't.
    CABasicAnimation * anchorAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    anchorAnimation.fromValue = [NSValue valueWithCGPoint:[self.frontViewController.view.layer.presentationLayer anchorPoint]];
    anchorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anchorAnimation.duration = duration;
    [self.frontViewController.view.layer addAnimation:anchorAnimation forKey:@"anchorPoint"];
}

/****************************************************************************/
#pragma mark Switch Visible View Controller

- (IBAction) switchVisibleViewController
{
    [self switchVisibleViewControllerAnimated:YES completion:nil];
}

- (IBAction) showBackViewController
{
    [self showBackViewControllerAnimated:YES completion:nil];
}

- (IBAction) showFrontViewController
{
    [self showFrontViewControllerAnimated:YES completion:nil];
}

- (void) switchVisibleViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion
{
    if(self.visibleViewController==self.frontViewController)
        [self showBackViewControllerAnimated:animated completion:completion];
    else
        [self showFrontViewControllerAnimated:animated completion:completion];
}

- (void) showBackViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion
{
    self.frontViewController.view.userInteractionEnabled = NO;
    self.visibleViewController = self.backViewController;
    
    CGFloat fromAngle = 0;
    CGFloat toAngle = kFanOpenAngle;
    
    [self rotateFrontVCFromAngle:fromAngle toAngle:toAngle animated:animated completion:completion];
}

- (void) showFrontViewControllerAnimated:(BOOL)animated completion:(void(^)(void)) completion
{
    self.frontViewController.view.userInteractionEnabled = YES;
    self.visibleViewController = self.frontViewController;
    
    CGFloat fromAngle = kFanOpenAngle;
    CGFloat toAngle = 0;
    
    [self rotateFrontVCFromAngle:fromAngle toAngle:toAngle animated:animated completion:completion];
}


- (void) rotateFrontVCFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle animated:(BOOL)animated completion:(void(^)(void)) completion
{
    // We can't animate on transform.rotation.z, because the view already has a transform
    // and we couldn't get the presentation value for transform.rotation.z.
    // (We later compute the angle manually)
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    id presentationValue = [self.frontViewController.view.layer.presentationLayer valueForKey:@"transform"];
    id modelValue = [self.frontViewController.view.layer.modelLayer valueForKey:@"transform"];
    
    // Animate from the current presentation angle
    CATransform3D presentationTransform = [presentationValue CATransform3DValue];
    CGFloat currentAngle = atan2f(presentationTransform.m12, presentationTransform.m11);
    
    animation.fromValue = presentationValue;
    // we rotate on the current transform, which is probably not identity.
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate([modelValue CATransform3DValue], toAngle, 0, 0, 1)];
    
    // ... for a fraction of the duration, depending on the actual angle we must animate
    if(animated)
        animation.duration = kFanAnimationDuration*((toAngle-currentAngle)/(toAngle-fromAngle));
    else
        animation.duration = 0;
    
    // We never remove this animation. It actually makes things easier because the frontViewController's model layer geometry is left untouched.
    animation.removedOnCompletion = NO;

    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeBoth;
    
    [CATransaction begin];
    if(completion)
        [CATransaction setCompletionBlock:completion];
    [self.frontViewController.view.layer addAnimation:animation forKey:@"rotation"];
    [CATransaction commit];
}

@end

/****************************************************************************/
#pragma mark -

@implementation UIViewController (FanContainedViewController)

- (BOOL) isVisibleViewController
{
    return [(FanContainerViewController*)self.parentViewController visibleViewController] == self;
}

@end
