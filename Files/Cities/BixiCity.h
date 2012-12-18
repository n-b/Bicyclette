//
//  BixiCity.h
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

@interface _BixiCity : _BicycletteCity

- (NSString *) titleForStation:(Station *)station;

- (BOOL) hasRegions; // NO
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;

@end

