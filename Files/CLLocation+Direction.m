//
//  CLLocation+Direction.m
//  Bicyclette
//
//  Created by Nicolas on 11/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "CLLocation+Direction.h"


@implementation CLLocation(Direction)

- (CLLocationDirection) directionToLocation:(CLLocation*)otherLocation
{
	double angle = - atan( (self.coordinate.longitude - otherLocation.coordinate.longitude) / 
						  (self.coordinate.latitude - otherLocation.coordinate.latitude) ) *180.0/M_PI;
	if(angle<0)
		angle+=360.0;
	return angle;
}


- (CLLocationDirection) directionFromLocation:(CLLocation*)otherLocation
{
	return [otherLocation directionToLocation:self];
}


- (NSString*) routeDescriptionToLocation:(CLLocation*)otherLocation usingShortFormat:(BOOL)shortFormat
{
	CLLocationDistance distance = [self distanceFromLocation:otherLocation];
	CLLocationDirection direction = [self directionToLocation:otherLocation];
	
	return [NSString stringWithFormat:@"%.0f %@ au %@",
			distance<1000?distance:distance/1000,
			distance<1000?@"m":@"km",
			shortFormat?[NSString directionShortDescription:direction]:[NSString directionDescription:direction]];
}

- (NSString*) routeDescriptionFromLocation:(CLLocation*)otherLocation usingShortFormat:(BOOL)shortFormat
{
	return [otherLocation routeDescriptionToLocation:self usingShortFormat:shortFormat];
}

- (NSString*) routeDescriptionToLocation:(CLLocation*)otherLocation
{
	return [self routeDescriptionToLocation:otherLocation usingShortFormat:NO];
}

- (NSString*) routeDescriptionFromLocation:(CLLocation*)otherLocation
{
	return [self routeDescriptionFromLocation:otherLocation usingShortFormat:NO];
}

@end

/****************************************************************************/
#pragma mark -

@implementation NSString (Direction)

+ (id) directionDescription:(CLLocationDirection)direction
{
	NSUInteger index = (NSUInteger)fmod(direction+22.5,360)*16/360;
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
	NSUInteger index = (NSUInteger)fmod(direction+22.5,360)*16/360;
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
