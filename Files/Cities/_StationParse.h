//
//  _StationParse.h
//  
//
//  Created by Nicolas on 11/01/13.
//
//

@class Station;

@interface _StationParse : NSObject
+ (NSDictionary*) stationAttributesWithData:(NSData*)data;
@end

@protocol StationParse
- (void) parseData:(NSData*)data;
@end

@interface XMLSubnodesStationParse : _StationParse <StationParse, NSXMLParserDelegate>
@end
