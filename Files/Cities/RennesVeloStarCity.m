//
//  RennesVeloStarCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "NSStringAdditions.h"

@interface RennesVeloStarCity : XMLSubnodesCity
@end

@implementation RennesVeloStarCity

- (NSArray *)updateURLStrings
{
    NSString * urlstring = [super updateURLStrings][0];
    NSString * key = self.accountInfo[@"apikey"];
    urlstring = [urlstring stringByReplacingOccurrencesOfString:@"{APIKEY}"
                                                     withString:key];
    return @[urlstring];
}

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

@end
