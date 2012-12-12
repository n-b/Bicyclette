//
//  NantesBiclooCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NantesBiclooCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation NantesBiclooCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.bicloo.nantesmetropole.fr/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.bicloo.nantesmetropole.fr/service/stationdetails/nantes/%@",station.number]];
}

/****************************************************************************/
#pragma mark CyclocityParsing

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = @"Nantes";
    regionInfo.name = @"Bicloo";
    
    return regionInfo;
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"Bicloo";
}

- (NSString*) titleForRegion:(Region*)region
{
    return @"Nantes";
}

- (NSString*) subtitleForRegion:(Region*)region
{
    return @"Bicloo";
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
