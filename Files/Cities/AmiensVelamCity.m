//
//  AmiensVelamCity.m
//  Bicyclette
//
//  Created by Nicolas on 17/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "AmiensVelamCity.h"
#import "BicycletteCity.mogenerated.h"

@implementation AmiensVelamCity

/****************************************************************************/
#pragma mark BicycletteParsing

- (NSURL*) updateURL
{
    return [NSURL URLWithString:@"http://www.velam.amiens.fr/service/carto"];
}

- (NSURL *) detailsURLForStation:(Station*)station
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.velam.amiens.fr/service/stationdetails/amiens/%@",station.number]];
}

/****************************************************************************/
#pragma mark BicycletteCityAnnotations

- (NSString*) title
{
    return @"Vélam";
}

@end
