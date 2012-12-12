//
//  BicycletteCities.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCities.h"
#import "SimpleCyclocityCity.h"
#import "MarseilleLeVeloCity.h"
#import "ParisVelibCity.h"

NSArray * BicycletteCityClasses(void)
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
             [LjubljanaBicikeljCity class],
             [LuxembourgVelohCity class],
             [MarseilleLeVeloCity class],
    		 [MulhouseVelociteCity class],
			 [NancyVelostanCity class],
             [NantesBiclooCity class],
             [ParisVelibCity class],
    		 [RouenCyclicCity class],
             [SantanderTusBicCity class],
             [SevillaSEViciCity class],
             [ToulouseVeloCity class],
             ];
}
