//
//  CyclocityCity.h
//  
//
//  Created by Nicolas on 12/12/12.
//
//

#import "BicycletteCity.h"

// Common code for all Cyclocity systems
@interface CyclocityCity : BicycletteCity <BicycletteCityParsing>
@end

// Simpler cities
@interface SimpleCyclocityCity : CyclocityCity
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
