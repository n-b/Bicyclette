//
//  _StationParse.m
//  
//
//  Created by Nicolas on 11/01/13.
//
//

#import "_StationParse.h"
#import "BicycletteCity.mogenerated.h"
#import "BicycletteCity.h"

// Let me call subclass methods
@interface _StationParse(StationParse) <StationParse>
@end

@interface _StationParse()
@property NSMutableDictionary * attributes;
@end

@implementation _StationParse
+ (NSDictionary*) stationAttributesWithData:(NSData*)data
{
    _StationParse * p = [self new];
    p.attributes = [NSMutableDictionary new];
    [p parseData:data];
    return p.attributes;
}
@end


@implementation XMLSubnodesStationParse
{
    NSMutableString * _currentString;
}

- (void) parseData:(NSData*)data
{
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    _currentString = [NSMutableString string];
    [parser parse];
    _currentString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString * value = [_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.attributes setObject:value forKey:elementName];
    
    _currentString = [NSMutableString string];
}

@end
