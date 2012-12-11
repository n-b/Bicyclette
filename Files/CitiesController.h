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
@property MKCoordinateRegion referenceRegion;
@property (assign) id<CitiesControllerDelegate> delegate;
- (void) reloadData;
- (void) regionDidChange:(MKCoordinateRegion)region;
- (void) handleLocalNotificaion:(UILocalNotification*)notification;
@end


@protocol CitiesControllerDelegate <NSObject>
- (void) setRegion:(MKCoordinateRegion)region;
- (MKCoordinateRegion)region;
- (void) setAnnotations:(NSArray*)newAnnotations;
- (void) selectAnnotation:(id<MKAnnotation>)annotation;
@end
