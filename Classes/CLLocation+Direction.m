//
//  CLLocation+Direction.m
//  Bicyclette
//
//  Created by Nicolas on 11/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+Direction.h"


@implementation CLLocation(Direction)
- (CLLocationDirection) directionTo:(CLLocation*)otherLocation
{
	double angle = - atan( (self.coordinate.longitude - otherLocation.coordinate.longitude) / 
						  (self.coordinate.latitude - otherLocation.coordinate.latitude) ) *180.0/M_PI;
	if(angle<0)
		angle+=360.0;
	return angle;
}


- (CLLocationDirection) directionFrom:(CLLocation*)otherLocation
{
	return [otherLocation directionTo:self];
}
@end


@implementation NSString (Direction)
+ (id) directionDescription:(CLLocationDirection)direction
{
	int index = fmod(direction+22.5,360)*16/360;
	static NSArray * descriptions = nil;
	if(nil==descriptions)
		descriptions = [[NSArray alloc] initWithObjects:
						NSLocalizedString(@"Nord",@""),NSLocalizedString(@"Nord-Nord-Ouest",@""),NSLocalizedString(@"Nord-Ouest",@""),NSLocalizedString(@"Ouest-Nord-Ouest",@""),
						NSLocalizedString(@"Ouest",@""),NSLocalizedString(@"Ouest-Sud-Ouest",@""),NSLocalizedString(@"Sud-Ouest",@""),NSLocalizedString(@"Sud-Sud-Ouest",@""),
						NSLocalizedString(@"Sud",@""),NSLocalizedString(@"Sud-Sud-Est",@""),NSLocalizedString(@"Sud-Est",@""),NSLocalizedString(@"Est-Sud-Est",@""),
						NSLocalizedString(@"Est",@""),NSLocalizedString(@"Est-Nord-Est",@""),NSLocalizedString(@"Nord-Est",@""),NSLocalizedString(@"Nord-Nord-Est",@""),nil];
	return [descriptions objectAtIndex:index];
}

+ (id) directionShortDescription:(CLLocationDirection)direction
{
	int index = fmod(direction+22.5,360)*16/360;
	static NSArray * descriptions = nil;
	if(nil==descriptions)
		descriptions = [[NSArray alloc] initWithObjects:
						NSLocalizedString(@"N",@""),NSLocalizedString(@"N-NO",@""),NSLocalizedString(@"NO",@""),NSLocalizedString(@"O-NO",@""),
						NSLocalizedString(@"O",@""),NSLocalizedString(@"O-SO",@""),NSLocalizedString(@"SO",@""),NSLocalizedString(@"S-SO",@""),
						NSLocalizedString(@"S",@""),NSLocalizedString(@"S-SE",@""),NSLocalizedString(@"SE",@""),NSLocalizedString(@"E-SE",@""),
						NSLocalizedString(@"E",@""),NSLocalizedString(@"E-NE",@""),NSLocalizedString(@"NE",@""),NSLocalizedString(@"N-NE",@""),nil];
	return [descriptions objectAtIndex:index];
}

@end
