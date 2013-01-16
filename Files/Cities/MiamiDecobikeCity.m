//
//  MiamiDecobikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
#import "NSStringAdditions.h"

@interface MiamiDecobikeCity : _XMLCityWithStationDataInSubnodes
@end

@implementation MiamiDecobikeCity

#pragma mark Annotations

- (NSString *)titleForStation:(Station *)station
{
    return [NSString stringWithFormat:@"%@ - %@",station.number, station.name];
}

@end
