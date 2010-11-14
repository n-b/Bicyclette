//
//  NSDate+IntervalDescription.m
//  Bicyclette
//
//  Created by Nicolas on 14/11/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "NSDate+IntervalDescription.h"


@implementation NSDate(IntervalDescription)

- (NSString*) intervalDescription
{
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
	if(interval<60)
		return NSLocalizedString(@"A l'instant",@"");
	if(interval<60*60)
		return [NSString stringWithFormat:NSLocalizedString(@"il y a %.0f minutes",@""),interval/60];
	else
		return NSLocalizedString(@"longtemps",@"");
}

@end
