//
//  DublinBikesCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "DublinBikesCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation DublinBikesCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.dublinbikes.ie/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.dublinbikes.ie/service/stationdetails/dublin/%@",station.number]];
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"dublinbikes";
}

@end
