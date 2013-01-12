//
//  _XMLCityWithStationDataInSubnodes
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+Update.h"

@interface _XMLCityWithStationDataInSubnodes : BicycletteCity
- (void) parseData:(NSData*)data;
@end

// To be implemented by subclasses
@protocol XMLCityWithStationDataInSubnodes <BicycletteCity>
- (NSString*) stationElementName;
@end

