//
//  MontpellierVelomaggCity.m
//  Bicyclette
//
//  Created by Nicolas on 02/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

#pragma mark -

@interface MontpellierVelomaggCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
@end

@implementation MontpellierVelomaggCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [[[station.name stringByTrimmingZeros] stringByDeletingPrefix:station.number] stringByTrimmingWhitespace]; }

#pragma mark City Data Update

- (NSString*) stationElementName
{
    return @"si";
}

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return values[@"id"];
}

- (NSDictionary*) KVCMapping
{
    return @{@"id" : StationAttributes.number,
             @"la" : StationAttributes.latitude,
             @"lg": StationAttributes.longitude,
             @"na" : StationAttributes.name,
             @"av" : StationAttributes.status_available,
             @"fr" : StationAttributes.status_free,
             @"to" : StationAttributes.status_total};
}

@end
