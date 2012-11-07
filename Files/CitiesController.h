//
//  CitiesController.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 07/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteCity;

typedef enum {
	MapLevelNone = 0,
	MapLevelRegions,
	MapLevelRegionsAndRadars,
	MapLevelStationsAndRadars
}  MapLevel;

@protocol CitiesControllerDelegate;

@interface CitiesController : NSObject

@property NSArray * cities;

@property (nonatomic) BicycletteCity * currentCity;
@property MKCoordinateRegion referenceRegion;
@property (nonatomic) MapLevel level;

@property (assign) id<CitiesControllerDelegate> delegate;

- (void) reloadData;

- (void) regionDidChange:(MKCoordinateRegion)region;

@end

@protocol CitiesControllerDelegate <NSObject>

- (void) setRegion:(MKCoordinateRegion)region;

- (MKCoordinateRegion)region;

- (void) setAnnotations:(NSArray*)newAnnotations;
@end
