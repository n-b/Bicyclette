//
//  _XMLCityWithStationDataInAttributes.m
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"

// Allow me to call methods of subclasses
@interface _XMLCityWithStationDataInAttributes (XMLCityWithStationDataInAttributes) <XMLCityWithStationDataInAttributes>
@end

#pragma mark -
@interface _XMLCityWithStationDataInAttributes () <NSXMLParserDelegate>
@end

@implementation _XMLCityWithStationDataInAttributes

- (void) fuckParseData:(NSData*)data
{
    // Parse stations XML
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];   
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:[self stationElementName]]) // End of station dict
    {
        NSString * stationNumber = [self stationNumberFromStationValues:attributeDict];
        [self setValues:attributeDict toStationWithNumber:stationNumber];
    }
}


@end
