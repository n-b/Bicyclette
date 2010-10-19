//
//  VelibDataManager.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/****************************************************************************/
#pragma mark -

@interface VelibDataManager : NSObject
- (id) init;
- (id) initWithVelibXML:(NSData*)xml;
@property (nonatomic, retain, readonly) NSArray * stations;
@property (nonatomic, retain, readonly) NSArray * sections;
@end

/****************************************************************************/
#pragma mark -

@interface Section : NSObject
@property (nonatomic, retain, readonly) NSString * name;
@property (nonatomic, retain, readonly) NSArray * stations;
@end

/****************************************************************************/
#pragma mark -

@interface Station : NSObject 
// data
@property (nonatomic, retain, readonly) NSString * name;
@property (nonatomic, retain, readonly) NSString * number;
@property (nonatomic, retain, readonly) NSString * address;
@property (nonatomic, retain, readonly) NSString * fullAddress;
@property (nonatomic, readonly) CLLocationDegrees lat;
@property (nonatomic, readonly) CLLocationDegrees lng;
@property (nonatomic, readonly) BOOL open;
@property (nonatomic, readonly) BOOL bonus;

@property (nonatomic, assign, readonly) Section * section;
@property (nonatomic, retain, readonly) NSDate * refreshDate;
// status

- (void) refresh;

@property unsigned int available;
@property unsigned int free;
@property unsigned int total;
@property BOOL ticket;

@end
