//
//  XMLCityWithStationDataInSubnodes.h
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _XMLCityWithStationDataInSubnodes : _BicycletteCity <NSXMLParserDelegate>
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;
@end

// To be implemented by subclasses
@protocol XMLCityWithStationDataInSubnodes <BicycletteCity>
- (NSString*) stationElementName;
- (NSDictionary*) KVCMapping;
@end
