//
//  BicycletteCities.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCities.h"

#import "CyclocityCities.h"
#import "MarseilleLeVeloCity.h"
#import "ParisVelibCity.h"
#import "LyonVelovCity.h"

#import "BixiCity.h"

#import "OrleansVeloPlusCity.h"

#import "RennesVeloStarCity.h"

#import "LaRochelleYeloCity.h"

#import "MelbourneBikeShareCity.h"

#import "ChattanoogaBikeCity.h"

NSArray * BicycletteCities(void)
{
    NSArray * cities = @[
                         [AmiensVelamCity new],
                         [BesanconVelociteCity new],
                         [BrisbaneCityCycleCity new],
                         [BruxellesVilloCity new],
                         [CergyPointoiseVelO2City new],
                         [CreteilCristoLibCity new],
                         [DublinBikesCity new],
                         [GoteborgStyrStallCity new],
                         [LjubljanaBicikeljCity new],
                         [LuxembourgVelohCity new],
                         [MulhouseVelociteCity new],
                         [NancyVelostanCity new],
                         [NantesBiclooCity new],
                         [RouenCyclicCity new],
                         [SantanderTusBicCity new],
                         [SevillaSEViciCity new],
                         [ToulouseVeloCity new],
                         [ToyamaCyclOcityCity new],
                         [ValenciaValenbisiCity new],
                         [ParisVelibCity new],
                         [MarseilleLeVeloCity new],
                         [LyonVelovCity new],
                         
                         
                         [OrleansVeloPlusCity new],
                         
                         [RennesVeloStarCity new],
                         
                         [LaRochelleYeloCity new],
                         
                         [MelbourneBikeShareCity new],
                         
                         [ChattanoogaBikeCity new],
                         ];
    
    cities = [cities arrayByAddingObjectsFromArray:[BixiCity allBIXICities]];
    return cities;
}
