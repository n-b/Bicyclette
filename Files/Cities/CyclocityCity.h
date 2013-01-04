//
//  CyclocityCity.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"

// Common code for all Cyclocity systems (except Velov)
@interface CyclocityCity : _XMLCityWithStationDataInAttributes <XMLCityWithStationDataInAttributes>
- (NSString*) stationElementName;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
- (NSDictionary*) KVCMapping;
@end

