//
//  NancyVelostanCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NancyVelostanCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation NancyVelostanCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.velostanlib.fr/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.velostanlib.fr/service/stationdetails/nancy/%@",station.number]];
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"Vélostan";
}

@end
