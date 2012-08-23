//
//  HelpVC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 23/08/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "HelpVC.h"

@interface HelpVC () <UIScrollViewDelegate>
@property (weak) IBOutlet UIView *box;
@property (weak) IBOutlet UIScrollView *scrollView;
@property (weak) IBOutlet UIView *contentView;
@property (weak) IBOutlet UIPageControl *pageControl;
@end

@implementation HelpVC
@synthesize box = _box;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.box.layer.cornerRadius = 13;
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = self.contentView.bounds.size;
}

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

- (void)viewDidUnload {
    [self setBox:nil];
    [super viewDidUnload];
}
@end
