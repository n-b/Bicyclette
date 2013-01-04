//
//  TempCityClass.h
//  
//
//  Created by Nicolas on 04/01/13.
//
//

#import "BicycletteCity.h"

@interface _FuckCity : _BicycletteCity
- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations;
- (void) setValues:(NSDictionary*)values
toStationWithNumber:(NSString*)stationNumber;
@end

// To be implemented by subclasses
@protocol FuckCity <BicycletteCity>
- (void) fuckParseData:(NSData*)data;
- (NSDictionary*) KVCMapping;
@end

