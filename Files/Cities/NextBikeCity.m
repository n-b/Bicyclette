//
//  NextBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"

@interface NextBikeCity : XMLAttributesCity
@end

@implementation NextBikeCity

#pragma mark City Data Update

- (NSArray *) updateURLStrings
{
    if( self.serviceInfo[@"regions"] )
    {
        NSString * baseURL = self.serviceInfo[@"update_url"];
        NSDictionary * regions = self.serviceInfo[@"regions"];
        NSMutableArray * result = [NSMutableArray new];
        for (NSString * regionID in regions) {
            [result addObject:[baseURL stringByAppendingString:regionID]];
        }
        return result;
    }
    else
    {
        return [super updateURLStrings];
    }
}

@end
