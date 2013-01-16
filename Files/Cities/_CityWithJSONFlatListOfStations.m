//
//  _CityWithJSONFlatListOfStations
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_CityWithJSONFlatListOfStations.h"
#import "BicycletteCity+ServiceDescription.h"

// Allow me to call methods of subclasses
@interface _CityWithJSONFlatListOfStations (CityWithJSONFlatListOfStations) <CityWithJSONFlatListOfStations>
@end

@implementation _CityWithJSONFlatListOfStations
- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    NSError * error;
    id res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(!res)
        NSLog(@"Error parsing JSON in %@ : %@",self,error);
    
    if([self respondsToSelector:@selector(keyPathToStationsLists)])
    {
        if([res isKindOfClass:[NSDictionary class]])
        {
            res = [res valueForKeyPath:[self keyPathToStationsLists]];
        }
        else
        {
            NSLog(@"Error parsing JSON in %@ : result should be a dictionary",self);
            res = nil;
        }
    }
    
    if(![res isKindOfClass:[NSArray class]])
    {
        NSLog(@"Error parsing JSON in %@ : result should be an array",self);
        res = nil;
    }
    return res;
}
@end

@implementation _CityWithJSONFlatListOfStations (ServiceDescription)

- (NSMutableDictionary *)fullServiceInfo
{
    NSMutableDictionary * info = [super fullServiceInfo];
    if([self respondsToSelector:@selector(keyPathToStationsLists)])
        [info setObject:[self keyPathToStationsLists] forKey:@"keypath_to_stations_lists"];
    return info;
}

@end
