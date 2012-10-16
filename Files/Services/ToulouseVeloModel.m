//
//  ToulouseVeloModel.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "ToulouseVeloModel.h"
#import "Station.h"
#import "Region.h"

@implementation ToulouseVeloModel

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = @"Toulouse";
    regionInfo.name = @"Toulouse";
    
    return regionInfo;
}

- (NSString*)titleForRegion:(Region*)region
{
    return @"Toulouse";
}

- (NSString*)subtitleForRegion:(Region*)region
{
    return @"";
}

- (NSString*)titleForStation:(Station*)region
{
    // remove number
    NSString * shortname = region.name;
    NSRange beginRange = [shortname rangeOfString:@"-"];
    if (beginRange.location!=NSNotFound)
        shortname = [region.name substringFromIndex:beginRange.location+beginRange.length];
    
    // remove whitespace
    shortname = [shortname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // capitalized
    if([shortname respondsToSelector:@selector(capitalizedStringWithLocale:)])
        shortname = [shortname capitalizedStringWithLocale:[NSLocale currentLocale]];
    else
        shortname = [shortname stringByReplacingCharactersInRange:NSMakeRange(1, shortname.length-1) withString:[[shortname substringFromIndex:1] lowercaseString]];
    
    return shortname;
}

@end
