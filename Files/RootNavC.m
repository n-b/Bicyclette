//
//  RootNavC.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 29/09/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "RootNavC.h"

@implementation RootNavC

- (BOOL) shouldAutorotate
{
    // either the mapVC or the prefsVC
    return [[self visibleViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
