//
//  _XMLCityWithStationDataInAttributes.m
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "_XMLCityWithStationDataInAttributes.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "BicycletteCity+ServiceDescription.h"

// Allow me to call methods of subclasses
@interface _XMLCityWithStationDataInAttributes (XMLCityWithStationDataInAttributes) <XMLCityWithStationDataInAttributes>
@end

#pragma mark -

@interface _XMLCityWithStationDataInAttributes () <NSXMLParserDelegate>
@end

@implementation _XMLCityWithStationDataInAttributes

- (void) parseData:(NSData*)data
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
        [self insertStationWithAttributes:attributeDict];
    }
}

@end


@implementation _XMLCityWithStationDataInAttributes (ServiceDescription)

- (NSMutableDictionary *)fullServiceInfo
{
    NSMutableDictionary * info = [super fullServiceInfo];
    [info setObject:[self stationElementName] forKey:@"station_element_name"];
    return info;
}

@end
