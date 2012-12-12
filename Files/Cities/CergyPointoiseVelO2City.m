//
//  CergyPointoiseVelO2City.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CergyPointoiseVelO2City.h"
#import "BicycletteCity.mogenerated.h"

@implementation CergyPointoiseVelO2City

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.velo2.cergypontoise.fr/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.velo2.cergypontoise.fr/service/stationdetails/cergy/%@",station.number]];
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"VélO2";
}

@end
