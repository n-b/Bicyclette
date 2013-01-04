//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLCityWithStationDataInSubnodes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface RennesVeloStarCity : _XMLCityWithStationDataInSubnodes <XMLCityWithStationDataInSubnodes>
@end

@implementation RennesVeloStarCity

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

#pragma mark City Data Update

- (NSDictionary*) KVCMapping
{
    return @{@"number" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"state" : StationAttributes.open,
             @"latitude" : StationAttributes.latitude,
             @"longitude": StationAttributes.longitude,
             @"slotsavailable": StationAttributes.status_free,
             @"bikesavailable": StationAttributes.status_available,
             @"pos":StationAttributes.status_ticket,
             };
}

- (NSString*) stationElementName
{
    return @"station";
}

- (NSString*) stationNumberFromStationValues:(NSDictionary*)values
{
    return values[@"number"];
}

- (NSString *)regionNumberFromStationValues:(NSDictionary *)values
{
    return values[@"district"];
}

@end
