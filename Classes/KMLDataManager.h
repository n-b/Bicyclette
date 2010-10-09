//
//  KMLDataManager.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Visuamobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/****************************************************************************/
#pragma mark -

@interface KMLDataManager : NSObject
+ (id) managerWithKML:(NSString*)kml;
- (id) initWithKML:(NSString*)kml;
@property (nonatomic, retain, readonly) NSArray * arrondissements;
@end

/****************************************************************************/
#pragma mark -

@interface Arrondissement : NSObject 
@property (nonatomic, retain, readonly) NSString * xmlID;
@property (nonatomic, retain, readonly) NSString * name;
@property (nonatomic, retain, readonly) NSArray * stations;
@end

/****************************************************************************/
#pragma mark -

@interface Station : NSObject 
// data
@property (nonatomic, retain, readonly) NSString * xmlID;
@property (nonatomic, retain, readonly) NSString * name;
@property (nonatomic, retain, readonly) NSString * displayName;
@property (nonatomic, retain, readonly) NSString * address;
@property (nonatomic, retain, readonly) CLLocation * location;
@property (nonatomic, assign, readonly) Arrondissement * arrondissement;

// status
@property unsigned int available;
@property unsigned int free;
@property unsigned int total;
@property BOOL ticket;

@end
