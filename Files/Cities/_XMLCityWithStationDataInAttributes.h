//
//  _XMLCityWithStationDataInAttributes.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _XMLCityWithStationDataInAttributes : _BicycletteCity
- (void) parseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol XMLCityWithStationDataInAttributes <BicycletteCity>
- (NSString*) stationElementName;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
@end
