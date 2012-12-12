//
//  GoteborgStyrStallCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "GoteborgStyrStallCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation GoteborgStyrStallCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.goteborgbikes.se/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.goteborgbikes.se/service/stationdetails/goteborg/%@",station.number]];
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"Styr & Ställ";
}

@end
