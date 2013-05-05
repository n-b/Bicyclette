//
//  ViaCycleCity.m
//  Bicyclette
//
//  Created by Nicolas on 20/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"

@interface ViaCycleCity : FlatJSONListCity
@end

@implementation ViaCycleCity

- (NSDictionary *)KVCMapping
{
    return @{@"location.longitude": @"longitude",
             @"bikecount": @"status_available",
             @"number": @"number",
             @"name": @"name",
             @"location.latitude": @"latitude",
             @"address": @"address"
             };
}

- (NSString *)keyPathToStationsLists
{
    return @"zones";
}

@end
