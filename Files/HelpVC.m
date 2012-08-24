//
//  HelpVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 23/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "HelpVC.h"

@interface HelpVC () <UIScrollViewDelegate>
@property IBOutlet UIView *box;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UIView *contentView;
@property IBOutlet UIPageControl *pageControl;
@property IBOutlet UIImageView *logoView;
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

- (void) viewDidAppear:(BOOL)animated
{
 
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

@end
