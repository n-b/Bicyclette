//
//  AvignonPopCity.m
//  Bicyclette
//
//  Created by Nicolas on 18/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface AvignonPopCity : _BicycletteCity <BicycletteCity>
@end

@implementation AvignonPopCity

#pragma mark City Data Update

- (NSDictionary*) KVCMapping
{
    return @{@"number": StationAttributes.number,
             @"latitude" : StationAttributes.latitude,
             @"longitude": StationAttributes.longitude,
             @"name" : StationAttributes.name,
             @"availablebikes" : StationAttributes.status_available,
             @"freeslots" : StationAttributes.status_free,
             };
}

- (void) parseData:(NSData*)data
{
    NSString * string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    NSScanner * dataScanner = [NSScanner scannerWithString:string];

    while ([dataScanner scanUpToString:@"map.addOverlay(newmark_0" intoString:nil]) {
        [dataScanner scanString:@"map.addOverlay(newmark_0" intoString:nil];
        BOOL validEntry = YES;
        validEntry &= [dataScanner scanUpToString:@"(" intoString:nil];
        validEntry &= [dataScanner scanString:@"(" intoString:nil];

        NSString * entry;
        validEntry &= [dataScanner scanUpToString:@"))" intoString:&entry];
        
        NSScanner * entryScanner = [NSScanner scannerWithString:entry];

        NSInteger number;
        validEntry &= [entryScanner scanInteger:&number];
        validEntry &= [entryScanner scanString:@"," intoString:nil];

        CLLocationDegrees latitude, longitude;
        validEntry &= [entryScanner scanDouble:&latitude];
        validEntry &= [entryScanner scanString:@"," intoString:nil];
        validEntry &= [entryScanner scanDouble:&longitude];
        validEntry &= [entryScanner scanString:@"," intoString:nil];

        NSString * name;
        validEntry &= [entryScanner scanUpToString:@">" intoString:nil];
        validEntry &= [entryScanner scanString:@">" intoString:nil];
        validEntry &= [entryScanner scanUpToString:@"<" intoString:&name];

        NSInteger availablebikes;
        validEntry &= [entryScanner scanUpToString:@">Vélos disponibles: " intoString:nil];
        validEntry &= [entryScanner scanString:@">Vélos disponibles: " intoString:nil];
        validEntry &= [entryScanner scanInteger:&availablebikes];
        
        NSInteger freeslots;
        validEntry &= [entryScanner scanUpToString:@">Emplacements libres: " intoString:nil];
        validEntry &= [entryScanner scanString:@">Emplacements libres: " intoString:nil];
        validEntry &= [entryScanner scanInteger:&freeslots];
        
        if (validEntry) {
            [self insertStationAttributes:
             @{@"number": @(number),
             @"latitude": @(latitude),
             @"longitude": @(longitude),
             @"name": name,
             @"availablebikes": @(availablebikes),
             @"freeslots": @(freeslots)
             }];
        }
    }
}

@end
