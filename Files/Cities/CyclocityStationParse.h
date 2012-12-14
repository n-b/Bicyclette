//
//  CyclocityStationParse.h
//  Bicyclette
//
//  Created by Nicolas on 14/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class Station;

@interface CyclocityStationParse : NSObject
+ (void) parseData:(NSData*)data forStation:(Station*)station;
@end
