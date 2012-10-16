//
//  VelibModel.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "VelibModel.h"
#import "Station.h"
#import "Region.h"
#import "NSStringAdditions.h"

@implementation VelibModel

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    if( ! [station.fullAddress hasPrefix:station.address] )
        return nil;

    NSString * endOfAddress = [station.fullAddress stringByDeletingPrefix:station.address];
    endOfAddress = [endOfAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString * lCodePostal = nil;
    if(patchs[@"codePostal"])
    {
        // Stations Mobiles et autres bugs (93401 au lieu de 93400)
        lCodePostal = patchs[@"codePostal"];
    }
    else
    {
        // Code Postal / Number
        if(endOfAddress.length>=5)
            lCodePostal = [endOfAddress substringToIndex:5];
        if(nil==lCodePostal || [lCodePostal isEqualToString:@"75000"])
        {
            unichar firstChar = [station.number characterAtIndex:0];
            switch (firstChar) {
                case '0': case '1':				// Paris
                    lCodePostal = [NSString stringWithFormat:@"750%@",[station.number substringToIndex:2]];
                    break;
                case '2': case '3': case '4':	// Banlieue
                    lCodePostal = [NSString stringWithFormat:@"9%@0",[station.number substringToIndex:3]];
                    break;
                default:
                    // Dernier recours
                    lCodePostal = @"75000";
                    break;
            }
            
            NSLog(@"Note : Used heuristics to find region for %@. Found : %@. ",station, lCodePostal);
        }
    }

    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = lCodePostal;

    // City name
    if([lCodePostal hasPrefix:@"75"])
        regionInfo.name = [NSString stringWithFormat:@"Paris %@",[[lCodePostal substringFromIndex:3] stringByDeletingPrefix:@"0"]];
    else
    {
        NSString * cityName = [[[endOfAddress stringByDeletingPrefix:lCodePostal]
                                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                               capitalizedString];
        regionInfo.name = cityName;
    }
    return regionInfo;
}

- (NSString*)titleForRegion:(Region*)region
{
    return [region.number substringToIndex:2];
}

- (NSString*)subtitleForRegion:(Region*)region
{
    return [region.number substringFromIndex:2];
}

- (NSString*)titleForStation:(Station*)region
{
    // remove number
    NSString * shortname = region.name;
    NSRange beginRange = [shortname rangeOfString:@" - "];
    if (beginRange.location!=NSNotFound)
        shortname = [region.name substringFromIndex:beginRange.location+beginRange.length];
    
    // remove city name
    NSRange endRange = [shortname rangeOfString:@"("];
    if(endRange.location!=NSNotFound)
        shortname = [shortname substringToIndex:endRange.location];
    
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
