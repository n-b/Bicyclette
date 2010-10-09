//
//  BicycletteDefaults.m
//  Bicyclette
//
//  Created by Nicolas on 10/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteDefaults.h"


@implementation NSUserDefaults(BicycletteDefaults)

- (void) setLastKnownLocation:(CLLocation*) location
{
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:location] forKey:@"lastKnownLocation"];
	[self setObject:[NSDate date] forKey:@"lastKnownLocationDate"];
}

- (CLLocation*) lastKnownLocation
{
	if([[NSDate date] timeIntervalSinceDate:[self objectForKey:@"lastKnownLocationDate"]] < 15*60)
		return [NSKeyedUnarchiver unarchiveObjectWithData:[self objectForKey:@"lastKnownLocation"]];
	else
		return nil;
}

@end
