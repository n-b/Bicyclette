//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInSubnodes.h"
#import "NSStringAdditions.h"

@interface RennesVeloStarCity : _XMLCityWithStationDataInSubnodes
@end

@implementation RennesVeloStarCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

- (NSString *)regionNumberFromStationValues:(NSDictionary *)values
{
    return values[@"district"];
}

@end
