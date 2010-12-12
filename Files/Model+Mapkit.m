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
	return self.name;
}

- (NSString *)subtitle
{
	return self.address;
}

@end
