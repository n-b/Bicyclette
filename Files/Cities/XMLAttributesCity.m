//
//  XMLAttributesCity.m
//  Bicyclette
//
//  Created by Nicolas on 04/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLAttributesCity.h"
#import "BicycletteCity+ServiceDescription.h"

#pragma mark -

@interface XMLAttributesCity () <NSXMLParserDelegate>
@end

@implementation XMLAttributesCity

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

- (NSString*) stationElementName
{
    return self.serviceInfo[@"station_element_name"];
}

/****************************************************************************/
#pragma mark Service Description

- (NSMutableDictionary *)fullServiceInfo
{
    NSMutableDictionary * info = [super fullServiceInfo];
    [info setObject:[self stationElementName] forKey:@"station_element_name"];
    return info;
}

@end
