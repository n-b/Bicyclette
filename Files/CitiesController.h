//
//  CitiesController.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteCity;

@protocol CitiesControllerDelegate;

@interface CitiesController : NSObject
@property NSArray * cities;
@property (readonly, nonatomic) BicycletteCity * currentCity;
@property (assign) id<CitiesControllerDelegate> delegate;
- (void) regionDidChange:(MKCoordinateRegion)region;
- (void) handleLocalNotificaion:(UILocalNotification*)notification;
@end


@protocol CitiesControllerDelegate <NSObject>
- (void) controller:(CitiesController*)controller setRegion:(MKCoordinateRegion)region;
- (MKCoordinateRegion)regionForController:(CitiesController*)controller;
- (void) controller:(CitiesController*)controller setAnnotations:(NSArray*)newAnnotations;
- (void) controller:(CitiesController*)controller selectAnnotation:(id<MKAnnotation>)annotation;
@end
