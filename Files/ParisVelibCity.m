//
//  ParisVelibCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "ParisVelibCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@implementation ParisVelibCity

#pragma mark Annotations

- (NSString *) titleForRegion:(Region*)region { return [region.number substringToIndex:2]; }
- (NSString *) subtitleForRegion:(Region*)region { return [region.number substringFromIndex:2]; }

- (NSString *) titleForStation:(Station*)station
{
    NSString * title = [super titleForStation:station];

    // remove city name
    NSRange endRange = [title rangeOfString:@"("];
    if(endRange.location!=NSNotFound)
        title = [title substringToIndex:endRange.location];
    
    title = [title stringByTrimmingWhitespace];
    
    return title;
}

#pragma mark CyclocityCity

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
        NSLog(@"Note : Used hardcoded codePostal for station %@. Full Address: %@. Patch : %@.",station.number, station.fullAddress, lCodePostal);
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
            
            NSLog(@"Note : Used heuristics to find region for Station %@. Full Address: %@. Found from number : %@",station.number, station.fullAddress, lCodePostal);
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

@end
