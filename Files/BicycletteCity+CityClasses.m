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
#import "CergyPointoiseVelO2City.h"
#import "MarseilleLeVeloCity.h"
#import "NantesBiclooCity.h"
#import "ParisVelibCity.h"
#import "ToulouseVeloCity.h"

@implementation BicycletteCity (CityClasses)
+ (NSArray*) cityClasses
{
    return @[
             [AmiensVelamCity class],
             [BesanconVelociteCity class],
             [CergyPointoiseVelO2City class],
             [MarseilleLeVeloCity class],
             [NantesBiclooCity class],
             [ParisVelibCity class],
             [ToulouseVeloCity class],
             ];
}
@end
