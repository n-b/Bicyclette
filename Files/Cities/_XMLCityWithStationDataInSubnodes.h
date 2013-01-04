//
//  _XMLCityWithStationDataInSubnodes
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

#import "_FuckCity.h"

@interface _XMLCityWithStationDataInSubnodes : _FuckCity
- (void) fuckParseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol XMLCityWithStationDataInSubnodes <FuckCity>
- (NSString*) stationElementName;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
@end

