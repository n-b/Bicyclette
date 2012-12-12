//
//  MarseilleLeVeloCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MarseilleLeVeloCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation MarseilleLeVeloCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSString*) updateURLString
{
    return @"http://www.levelo-mpm.fr/service/carto";
}

- (NSString *) detailsURLStringForStation:(Station*)station
{
    return [NSString stringWithFormat:@"http://www.levelo-mpm.fr/service/stationdetails/marseille/%@",station.number];
}

/****************************************************************************/
#pragma mark CyclocityParsing

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = [station.name substringToIndex:1];
    regionInfo.name = [station.name substringToIndex:1];
    return regionInfo;
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"Le Vélo";
}

- (NSString*) titleForRegion:(Region*)region
{
    return [NSString stringWithFormat:@"%@°",region.number];
}

- (NSString*) subtitleForRegion:(Region*)region
{
    return @"arr.";
}

- (NSString*) titleForStation:(Station*)region
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
