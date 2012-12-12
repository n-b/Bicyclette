//
//  SimpleCyclocityCity.m
//  
//
//  Created by Nicolas on 12/12/12.
//
//

#import "SimpleCyclocityCity.h"
#import "BicycletteCity.mogenerated.h"

/****************************************************************************/
#pragma mark SimpleCycloCity

@implementation SimpleCyclocityCity

- (NSString*) titleForStation:(Station*)station
{
    // remove number
    NSString * shortname = station.name;
    NSRange beginRange = [shortname rangeOfString:@"-"];
    if (beginRange.location!=NSNotFound)
        shortname = [station.name substringFromIndex:beginRange.location+beginRange.length];
    
    // remove whitespace
    shortname = [shortname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // capitalized
    if([shortname respondsToSelector:@selector(capitalizedStringWithLocale:)])
        shortname = [shortname capitalizedStringWithLocale:[NSLocale currentLocale]];
    else
        shortname = [shortname stringByReplacingCharactersInRange:NSMakeRange(1, shortname.length-1) withString:[[shortname substringFromIndex:1] lowercaseString]];
    
    return shortname;
}

@end

/****************************************************************************/
#pragma mark Cities

@implementation AmiensVelamCity
- (NSString*) updateURLString { return @"http://www.velam.amiens.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velam.amiens.fr/service/stationdetails/amiens/%@",station.number]; }
- (NSString*) title { return @"Vélam"; }
@end

@implementation BesanconVelociteCity
- (NSString*) updateURLString { return @"http://www.velocite.besancon.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velocite.besancon.fr/service/stationdetails/besancon/%@",station.number]; }
- (NSString*) title { return @"VéloCité"; }
@end

@implementation BrisbaneCityCycleCity
- (NSString*) updateURLString { return @"http://www.citycycle.com.au/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.citycycle.com.au/service/stationdetails/brisbane/%@",station.number]; }
- (NSString*) title { return @"CityCycle"; }
@end

@implementation BruxellesVilloCity
- (NSString*) updateURLString { return @"http://www.villo.be/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.villo.be/service/stationdetails/bruxelles/%@",station.number]; }
- (NSString*) title { return @"Villo!"; }
@end

@implementation CergyPointoiseVelO2City
- (NSString*) updateURLString { return @"http://www.velo2.cergypontoise.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velo2.cergypontoise.fr/service/stationdetails/cergy/%@",station.number]; }
- (NSString*) title { return @"VélO2"; }
@end

@implementation CreteilCristoLibCity
- (NSString*) updateURLString { return @"http://www.cristolib.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.cristolib.fr/service/stationdetails/creteil/%@",station.number]; }
- (NSString*) title { return @"CristoLib"; }
@end

@implementation DublinBikesCity
- (NSString*) updateURLString { return @"http://www.dublinbikes.ie/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.dublinbikes.ie/service/stationdetails/dublin/%@",station.number]; }
- (NSString*) title { return @"dublinbikes"; }
@end

@implementation GoteborgStyrStallCity
- (NSString*) updateURLString { return @"http://www.goteborgbikes.se/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.goteborgbikes.se/service/stationdetails/goteborg/%@",station.number]; }
- (NSString*) title { return @"Styr & Ställ"; }
@end

@implementation LjubljanaBicikeljCity
- (NSString*) updateURLString { return @"http://www.bicikelj.si/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.bicikelj.si/service/stationdetails/ljubljana/%@",station.number]; }
- (NSString*) title { return @"Bicike(LJ)"; }
@end

@implementation LuxembourgVelohCity
- (NSString*) updateURLString { return @"http://www.veloh.lu/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.veloh.lu/service/stationdetails/luxembourg/%@",station.number]; }
- (NSString*) title { return @"vel’oh"; }
@end

@implementation MulhouseVelociteCity
- (NSString*) updateURLString { return @"http://www.velocite.mulhouse.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velocite.mulhouse.fr/service/stationdetails/mulhouse/%@",station.number]; }
- (NSString*) title { return @"Vélocité"; }
@end

@implementation NancyVelostanCity
- (NSString*) updateURLString { return @"http://www.velostanlib.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velostanlib.fr/service/stationdetails/nancy/%@",station.number]; }
- (NSString*) title { return @"Vélostan"; }
@end

@implementation NantesBiclooCity
- (NSString*) updateURLString { return @"http://www.bicloo.nantesmetropole.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.bicloo.nantesmetropole.fr/service/stationdetails/nantes/%@",station.number]; }
- (NSString*) title { return @"Bicloo"; }
@end

@implementation RouenCyclicCity
- (NSString*) updateURLString { return @"http://cyclic.rouen.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://cyclic.rouen.fr/service/stationdetails/rouen/%@",station.number]; }
- (NSString*) title { return @"Cy’clic"; }
@end

@implementation SantanderTusBicCity
- (NSString*) updateURLString { return @"http://www.tusbic.es/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.tusbic.es/service/stationdetails/santander/%@",station.number]; }
- (NSString*) title { return @"TusBic"; }
@end

@implementation SevillaSEViciCity
- (NSString*) updateURLString { return @"http://www.sevici.es/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.sevici.es/service/stationdetails/seville/%@",station.number]; }
- (NSString*) title { return @"SEVici"; }
@end

@implementation ToulouseVeloCity
- (NSString*) updateURLString { return @"http://www.velo.toulouse.fr/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.velo.toulouse.fr/service/stationdetails/toulouse/%@",station.number]; }
- (NSString*) title { return @"VélÔ"; }
@end

@implementation ToyamaCyclOcityCity
- (NSString*) updateURLString { return @"http://www.cyclocity.jp/service/carto"; }
- (NSString*) detailsURLStringForStation:(Station*)station { return [NSString stringWithFormat:@"http://www.cyclocity.jp/service/stationdetails/toyama/%@",station.number]; }
- (NSString*) title { return @"CyclOcity"; }
@end
