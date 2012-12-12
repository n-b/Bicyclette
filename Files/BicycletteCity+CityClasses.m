//
//  BicycletteCity+CityClasses.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity+CityClasses.h"
#import "AmiensVelamCity.h"
#import "BesanconVelociteCity.h"
#import "BrisbaneCityCycleCity.h"
#import "BruxellesVilloCity.h"
#import "CergyPointoiseVelO2City.h"
#import "CreteilCristoLibCity.h"
#import "DublinBikesCity.h"
#import "GoteborgStyrStallCity.h"
#import "MarseilleLeVeloCity.h"
#import "MulhouseVelociteCity.h"
#import "NancyVelostanCity.h"
#import "NantesBiclooCity.h"
#import "ParisVelibCity.h"
#import "RouenCyclicCity.h"
#import "ToulouseVeloCity.h"

@implementation BicycletteCity (CityClasses)
+ (NSArray*) cityClasses
{
    return @[
             [AmiensVelamCity class],
             [BesanconVelociteCity class],
             [BrisbaneCityCycleCity class],
             [BruxellesVilloCity class],
             [CergyPointoiseVelO2City class],
    		 [CreteilCristoLibCity class],
             [DublinBikesCity class],
             [GoteborgStyrStallCity class],
             [MarseilleLeVeloCity class],
    		 [MulhouseVelociteCity class],
			 [NancyVelostanCity class],
             [NantesBiclooCity class],
             [ParisVelibCity class],
    		 [RouenCyclicCity class],
             [ToulouseVeloCity class],
             ];
}
@end
