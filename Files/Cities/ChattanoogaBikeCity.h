//
//  ChattanoogaBikeCity.h
//  Bicyclette
//
//  Created by Nicolas on 21/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _SimpleJSONBicycletteCity : _BicycletteCity
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;
@end

@interface ChattanoogaBikeCity : _SimpleJSONBicycletteCity <BicycletteCity>

@end
