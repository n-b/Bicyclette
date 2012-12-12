//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

// Common code for all Cyclocity systems (except Velov)
@interface CyclocityCity : BicycletteCity <BicycletteCityParsing>
@end

@interface RegionInfo : NSObject
@property NSString * number;
@property NSString * name;
@end

// Cities with multiple Regions
@protocol CyclocityCityParsing <NSObject>
@optional
- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs;
@end
