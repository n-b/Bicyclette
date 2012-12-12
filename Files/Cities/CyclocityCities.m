//
//  CyclocityCities.m
//  Bicyclette
//
//  Created by Nicolas on 12/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "CyclocityCities.h"
#import "BicycletteCity.mogenerated.h"

@implementation AmiensVelamCity
- (NSArray*) updateURLStrings { return @[ @"http://www.velam.amiens.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velam.amiens.fr/service/stationdetails/amiens/%@",station.number]; }
- (NSString*) title { return @"Vélam"; }
@end

@implementation BesanconVelociteCity
- (NSArray*) updateURLStrings { return @[ @"http://www.velocite.besancon.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velocite.besancon.fr/service/stationdetails/besancon/%@",station.number]; }
- (NSString*) title { return @"VéloCité"; }
@end

@implementation BrisbaneCityCycleCity
- (NSArray*) updateURLStrings { return @[ @"http://www.citycycle.com.au/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.citycycle.com.au/service/stationdetails/brisbane/%@",station.number]; }
- (NSString*) title { return @"CityCycle"; }
@end

@implementation BruxellesVilloCity
- (NSArray*) updateURLStrings { return @[ @"http://www.villo.be/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.villo.be/service/stationdetails/bruxelles/%@",station.number]; }
- (NSString*) title { return @"Villo!"; }
@end

@implementation CergyPointoiseVelO2City
- (NSArray*) updateURLStrings { return @[ @"http://www.velo2.cergypontoise.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velo2.cergypontoise.fr/service/stationdetails/cergy/%@",station.number]; }
- (NSString*) title { return @"VélO2"; }

@end

@implementation CreteilCristoLibCity
- (NSArray*) updateURLStrings { return @[ @"http://www.cristolib.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.cristolib.fr/service/stationdetails/creteil/%@",station.number]; }
- (NSString*) title { return @"CristoLib"; }
@end

@implementation DublinBikesCity
- (NSArray*) updateURLStrings { return @[ @"http://www.dublinbikes.ie/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.dublinbikes.ie/service/stationdetails/dublin/%@",station.number]; }
- (NSString*) title { return @"dublinbikes"; }
@end

@implementation GoteborgStyrStallCity
- (NSArray*) updateURLStrings { return @[ @"http://www.goteborgbikes.se/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.goteborgbikes.se/service/stationdetails/goteborg/%@",station.number]; }
- (NSString*) title { return @"Styr & Ställ"; }
@end

@implementation LjubljanaBicikeljCity
- (NSArray*) updateURLStrings { return @[ @"http://www.bicikelj.si/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.bicikelj.si/service/stationdetails/ljubljana/%@",station.number]; }
- (NSString*) title { return @"Bicike(LJ)"; }
@end

@implementation LuxembourgVelohCity
- (NSArray*) updateURLStrings { return @[ @"http://www.veloh.lu/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.veloh.lu/service/stationdetails/luxembourg/%@",station.number]; }
- (NSString*) title { return @"vel’oh"; }
@end

@implementation MulhouseVelociteCity
- (NSArray*) updateURLStrings { return @[ @"http://www.velocite.mulhouse.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velocite.mulhouse.fr/service/stationdetails/mulhouse/%@",station.number]; }
- (NSString*) title { return @"Vélocité"; }
@end

@implementation NancyVelostanCity
- (NSArray*) updateURLStrings { return @[ @"http://www.velostanlib.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velostanlib.fr/service/stationdetails/nancy/%@",station.number]; }
- (NSString*) title { return @"Vélostan"; }
@end

@implementation NantesBiclooCity
- (NSArray*) updateURLStrings { return @[ @"http://www.bicloo.nantesmetropole.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.bicloo.nantesmetropole.fr/service/stationdetails/nantes/%@",station.number]; }
- (NSString*) title { return @"Bicloo"; }
@end

@implementation RouenCyclicCity
- (NSArray*) updateURLStrings { return @[ @"http://cyclic.rouen.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://cyclic.rouen.fr/service/stationdetails/rouen/%@",station.number]; }
- (NSString*) title { return @"Cy’clic"; }
@end

@implementation SantanderTusBicCity
- (NSArray*) updateURLStrings { return @[ @"http://www.tusbic.es/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.tusbic.es/service/stationdetails/santander/%@",station.number]; }
- (NSString*) title { return @"TusBic"; }
@end

@implementation SevillaSEViciCity
- (NSArray*) updateURLStrings { return @[ @"http://www.sevici.es/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.sevici.es/service/stationdetails/seville/%@",station.number]; }
- (NSString*) title { return @"SEVici"; }
@end

@implementation ToulouseVeloCity
- (NSArray*) updateURLStrings { return @[ @"http://www.velo.toulouse.fr/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velo.toulouse.fr/service/stationdetails/toulouse/%@",station.number]; }
- (NSString*) title { return @"VélÔ"; }
@end

@implementation ToyamaCyclOcityCity
- (NSArray*) updateURLStrings { return @[ @"http://www.cyclocity.jp/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.cyclocity.jp/service/stationdetails/toyama/%@",station.number]; }
- (NSString*) title { return @"CyclOcity"; }
@end

@implementation ValenciaValenbisiCity
- (NSArray*) updateURLStrings { return @[ @"http://www.valenbisi.es/service/carto" ]; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.valenbisi.es/service/stationdetails/valence/%@",station.number]; }
- (NSString*) title { return @"Valenbisi"; }
@end

