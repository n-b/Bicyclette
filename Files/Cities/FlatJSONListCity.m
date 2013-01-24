//
//  FlatJSONListCity
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "FlatJSONListCity.h"
#import "BicycletteCity+ServiceDescription.h"

@implementation FlatJSONListCity

- (NSArray*) stationAttributesArraysFromData:(NSData*)data
{
    NSError * error;
    id res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(!res)
        DebugLog(@"Error parsing JSON in %@ : %@",self,error);
    
    if([self keyPathToStationsLists])
    {
        if([res isKindOfClass:[NSDictionary class]])
        {
            res = [res valueForKeyPath:[self keyPathToStationsLists]];
        }
        else
        {
            DebugLog(@"Error parsing JSON in %@ : result should be a dictionary",self);
            res = nil;
        }
    }
    
    if(![res isKindOfClass:[NSArray class]])
    {
        DebugLog(@"Error parsing JSON in %@ : result should be an array",self);
        res = nil;
    }
    return res;
}

- (NSString*) keyPathToStationsLists
{
    return self.serviceInfo[@"keypath_to_stations_lists"];
}

/****************************************************************************/
#pragma mark Service Description

- (NSMutableDictionary *)fullServiceInfo
{
    NSMutableDictionary * info = [super fullServiceInfo];
    if([self keyPathToStationsLists])
        [info setObject:[self keyPathToStationsLists] forKey:@"keypath_to_stations_lists"];
    return info;
}

@end
