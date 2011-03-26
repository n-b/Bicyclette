//
//  Model+Mapkit.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "Model+Mapkit.h"


@implementation Station (Mapkit) 

- (CLLocationCoordinate2D) coordinate
{
	return self.location.coordinate;
}

- (NSString *)title
{
	return self.statusDescription;
}

+ (NSSet*) keyPathsForValuesAffectingTitle
{
    return [NSSet setWithObject:@"statusDescription"];
}

- (NSString *)subtitle
{
	return self.name;
}

@end

@implementation Region (Mapkit) 

- (CLLocationCoordinate2D) coordinate
{
	return self.coordinateRegion.center;
}

- (NSString *)title
{
	return self.name;
}

- (NSString *)subtitle
{
	return [NSString stringWithFormat:NSLocalizedString(@"%d stations",@""),self.stations.count];
}

@end
