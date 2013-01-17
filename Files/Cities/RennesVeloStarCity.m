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

#pragma mark Annotations

- (NSString *) titleForStation:(Station *)station { return [station.name capitalizedStringWithCurrentLocale]; }

@end
