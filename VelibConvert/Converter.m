//
//  Converter.m
//  VelibConvert
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Converter.h"
#import "NSArrayAdditions.h"

@implementation Converter

- (void) run
{
	NSString * wd = [[NSFileManager defaultManager] currentDirectoryPath];
	NSArray * args = [[NSProcessInfo processInfo] arguments];
	if([args count]<2)
	{
		NSLog(@"Usage : %@ <input> <output>",[[args objectAtIndex:0] lastPathComponent]);
		return;
	}
	NSString * inPath = [wd stringByAppendingPathComponent:[args objectAtIndex:1]];
	NSString * outPath = nil;
	if([args count]>2)
		outPath = [wd stringByAppendingPathComponent:[args objectAtIndex:2]];
	else
		outPath = [[inPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
	
	NSXMLDocument * xml = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:inPath] options:0 error:NULL] autorelease];
	if(nil==xml)
	{
		NSLog(@"Not a valid input");
		return;
	}
	
	NSArray * arrondissementsXML = [xml nodesForXPath:@"kml/Document/Folder" error:NULL];
	NSMutableArray * arrondissementsArray = [NSMutableArray arrayWithCapacity:[arrondissementsXML count]];
	for (NSXMLNode * arrondissement in arrondissementsXML) {
		NSString * arrondissementName = [[[arrondissement children] firstObjectWithValue:@"name" forKey:@"name"] stringValue];
		NSArray * stationsXML = [arrondissement nodesForXPath:@"Placemark" error:NULL];
		NSMutableArray * stationsArray = [NSMutableArray arrayWithCapacity:[stationsXML count]];
		for (NSXMLNode * station in stationsXML) {
			NSString * stationName = [[[station children] firstObjectWithValue:@"name" forKey:@"name"] stringValue];
			NSString * description = [[[station children] firstObjectWithValue:@"description" forKey:@"name"] stringValue];
			NSString * address = [[[station children] firstObjectWithValue:@"address" forKey:@"name"] stringValue];
			NSString * coordinates = [[[[[station children] firstObjectWithValue:@"Point" forKey:@"name"] children]
									   firstObjectWithValue:@"coordinates" forKey:@"name"]stringValue];
			NSAssert4(stationName&&description&&address&&coordinates,@"invalid data %@, %@, %@, %@,",stationName,description,address,coordinates);
			NSDictionary * stationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
										 stationName,@"name",
										 description,@"description",
										 address,@"address",
										 coordinates,@"coordinates",
										 nil];
			[stationsArray addObject:stationDictionary];
		}
		NSDictionary * arrondissementDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
												   arrondissementName,@"name",
												   stationsArray,@"stations",
												   nil];
		[arrondissementsArray addObject:arrondissementDictionary];
	}
	[arrondissementsArray writeToFile:outPath atomically:NO];
	NSLog(@"done %@",outPath);
}

@end
