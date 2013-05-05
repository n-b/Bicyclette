//
//  ParisVelibCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "JCDecauxCity.h"
#import "NSStringAdditions.h"

@interface ParisVelibCity : JCDecauxCity
@end

@interface NSString (ParisTweaks)
- (NSString*) stringWithEndOfAddress;
@end

@implementation ParisVelibCity

#pragma mark Annotations

- (NSString *) titleForRegion:(Region*)region { return [region.number substringToIndex:2]; }
- (NSString *) subtitleForRegion:(Region*)region { return [region.number substringFromIndex:2]; }

- (NSString *) titleForStation:(Station*)station
{
    NSString * title = [super titleForStation:station];

    // remove city name
    NSRange endRange = [title rangeOfString:@"("];
    if(endRange.location!=NSNotFound)
        title = [title substringToIndex:endRange.location];
    
    title = [title stringByTrimmingWhitespace];
    
    return title;
}

#pragma mark CyclocityCity

- (RegionInfo*) regionInfoFromStation:(Station*)station values:(NSDictionary*)values patchs:(NSDictionary*)patchs requestURL:(NSString*)urlString
{
    NSString * endOfAddress = [station.address stringWithEndOfAddress];
    
    endOfAddress = [endOfAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString * lCodePostal = nil;
    if(patchs[@"codePostal"])
    {
        // Stations Mobiles et autres bugs (93401 au lieu de 93400)
        lCodePostal = patchs[@"codePostal"];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
            DebugLog(@"Note : Used hardcoded codePostal for station %@. Full Address: %@. Patch : %@.",station.number, station.address, lCodePostal);
    }
    else
    {
        // Code Postal / Number
        if(endOfAddress.length>=5)
            lCodePostal = [endOfAddress substringToIndex:5];
        if(nil==lCodePostal || [lCodePostal isEqualToString:@"75000"])
        {
            unichar firstChar = [station.number characterAtIndex:0];
            switch (firstChar) {
                case '0': case '1':				// Paris
                    lCodePostal = [NSString stringWithFormat:@"750%@",[station.number substringToIndex:2]];
                    break;
                case '2': case '3': case '4':	// Banlieue
                    lCodePostal = [NSString stringWithFormat:@"9%@0",[station.number substringToIndex:3]];
                    break;
                default:
                    // Dernier recours
                    lCodePostal = @"75000";
                    break;
            }
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                DebugLog(@"Note : Used heuristics to find region for Station %@. Full Address: %@. Found from number : %@",station.number, station.address, lCodePostal);
        }
    }

    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = lCodePostal;

    // City name
    if([lCodePostal hasPrefix:@"75"])
        regionInfo.name = [NSString stringWithFormat:@"Paris %@",[[lCodePostal substringFromIndex:3] stringByDeletingPrefix:@"0"]];
    else
    {
        NSString * cityName = [[[endOfAddress stringByDeletingPrefix:lCodePostal]
                                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                               capitalizedString];
        regionInfo.name = cityName;
    }
    return regionInfo;
}

@end

@implementation NSString (ParisTweaks)

- (NSString*) stringWithEndOfAddress
{
    NSArray * components = [self componentsSeparatedByString:@" - "];
    if([components count]>1) {
        return [components lastObject];
    }
    static NSRegularExpression * exp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        exp = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{5}" options:0 error:NULL];
    });
    NSTextCheckingResult * match = [exp firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if(match) {
        return [self substringFromIndex:[match range].location];
    } else {
        DebugLog(@"Note : End of address not found = %@",self);
        return @"";
    }
}

@end
