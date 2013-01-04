//
//  _XMLCityWithStationDataInAttributes.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_FuckCity.h"

@interface _XMLCityWithStationDataInAttributes : _FuckCity
- (void) fuckParseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol XMLCityWithStationDataInAttributes <FuckCity>
- (NSString*) stationElementName;
- (NSString*) stationNumberFromStationValues:(NSDictionary*)values;
@end
