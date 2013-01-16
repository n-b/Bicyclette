//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "NSStringAdditions.h"

@interface RennesVeloStarCity : XMLSubnodesCity
@end

@implementation RennesVeloStarCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

- (RegionInfo *)regionInfoFromStation:(Station *)station values:(NSDictionary *)values patchs:(NSDictionary *)patchs requestURL:(NSString *)urlString
{
    return [RegionInfo infoWithName:values[@"district"] number:values[@"district"]];
}

@end
