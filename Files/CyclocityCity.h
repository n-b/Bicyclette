//
//  CyclocityCity.h
//  
//
//  Created by Nicolas on 12/12/12.
//
//

#import "BicycletteCity.h"

@interface CyclocityCity : BicycletteCity <BicycletteCityParsing, BicycletteCityParsing>
@end

@interface RegionInfo : NSObject
@property NSString * number;
@property NSString * name;
@end

@protocol CyclocityCityParsing <NSObject>
- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs;
@end
