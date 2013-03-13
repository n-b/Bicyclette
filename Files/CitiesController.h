//
//  CitiesController.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteCity;
@class Station;

@protocol CitiesControllerDelegate;

@interface CitiesController : NSObject
@property NSArray * cities;
- (BicycletteCity*) cityNamed:(NSString*)cityName;
@property (readonly, nonatomic) BicycletteCity * currentCity;
@property (assign) id<CitiesControllerDelegate> delegate;
@property (nonatomic) BOOL mapViewIsMoving;
- (void) regionDidChange:(MKCoordinateRegion)region;
- (void) handleLocalNotificaion:(UILocalNotification*)notification;
- (void) selectStationNumber:(NSString*)stationNumber inCityNamed:(NSString*)cityName changeRegion:(BOOL)changeRegion;
- (void) selectCity:(BicycletteCity*)city_;
- (void) switchStarredStation:(Station*)station;
- (BOOL) cityHasFences:(BicycletteCity*)city_;
@end


@protocol CitiesControllerDelegate <NSObject>
- (void) controller:(CitiesController*)controller setRegion:(MKCoordinateRegion)region;
- (void) controller:(CitiesController*)controller setAnnotations:(NSArray*)newAnnotations overlays:(NSArray*)newOverlays;
- (void) controller:(CitiesController*)controller selectAnnotation:(id<MKAnnotation>)annotation;
@end
