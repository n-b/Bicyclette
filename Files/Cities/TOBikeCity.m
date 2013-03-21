//
//  TOBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 15/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "XMLSubnodesCity.h"
#import "BicycletteCity.mogenerated.h"
#import "NSStringAdditions.h"
#import "NSValueTransformer+TransformerKit.h"

@interface TOBikeCity : BicycletteCity <NSXMLParserDelegate>
@end

@implementation TOBikeCity
{
    NSMutableString * _parsing_currentString;
    NSMutableDictionary * _parsing_currentValues;
}

#pragma mark City Data Update

+ (void) initialize
{
    [NSValueTransformer registerValueTransformerWithName:@"NumberOf4" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]]){
                              return @([[value componentsSeparatedByString:@"4"] count]-1);
                          }
                          return nil;
                      }];
    [NSValueTransformer registerValueTransformerWithName:@"NumberOf0" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]]){
                              return @([[value componentsSeparatedByString:@"0"] count]-1);
                          }
                          return nil;
                      }];
    [NSValueTransformer registerValueTransformerWithName:@"TOBikeStationStatusTransformer" transformedValueClass:[NSString class]
                      returningTransformedValueWithBlock:^NSNumber*(NSString* value) {
                          if([value isKindOfClass:[NSString class]])
                          {
                              return @(![value boolValue]);
                          }
                          return @YES;
                      }];
}

- (NSArray *) updateURLStrings
{
    return self.serviceInfo[@"cityIDs"];
}

- (NSURLRequest*) updater:(DataUpdater*)updater requestForURLString:(NSString *)urlString
{
    NSString * postXMLText = @"<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
    "<soap12:Body>"
    "<ElencoStazioniPerComune xmlns=\"c://inetub/wwwroot/webservice/Service.asmx\">"
    "<UsernameRivenditore>{LOGIN}</UsernameRivenditore>"
    "<PasswordRivenditore>{PASSWORD}</PasswordRivenditore>"
    "<CodiceComune>{CITY_ID}</CodiceComune>"
    "</ElencoStazioniPerComune>"
    "</soap12:Body>"
    "</soap12:Envelope>";

    NSString * baseURL = self.serviceInfo[@"update_url"];
    NSString * cityID = urlString;
    postXMLText = [postXMLText stringByReplacingOccurrencesOfString:@"{LOGIN}" withString:self.accountInfo[@"login"]];
    postXMLText = [postXMLText stringByReplacingOccurrencesOfString:@"{PASSWORD}" withString:self.accountInfo[@"password"]];
    postXMLText = [postXMLText stringByReplacingOccurrencesOfString:@"{CITY_ID}" withString:cityID];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postXMLText dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/soap+xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (NSString*) stationElementName
{
    return self.serviceInfo[@"station_element_name"];
}

- (void) parseData:(NSData*)data
{
    // The "TOBike string" are bundled in the SOAP XML enveloppe.
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}

// SOAP XML Parsing
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:[self stationElementName]])
        _parsing_currentString = [NSMutableString new];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_parsing_currentString appendString:string];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:[self stationElementName]]){
        NSDictionary * attributes = [self parseTOBikeString:_parsing_currentString];
        [self insertStationWithAttributes:attributes];
        _parsing_currentString = nil;
    }
}

// TOBike String Parsing
- (NSDictionary*) parseTOBikeString:(NSString*)toBikeString
{
    NSMutableDictionary * attributes = [NSMutableDictionary new];
    NSArray * values = [toBikeString componentsSeparatedByString:@";"];
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        attributes[[NSString stringWithFormat:@"%d",(int)idx]] = obj;
    }];
    return attributes;
}

@end
