//
//  MapVC.h
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class VelibModel;

typedef enum {
	MapDisplayBikes,
	MapDisplayParking,
}  MapDisplay;

@interface MapVC : UIViewController 
@property (strong) VelibModel * model;
@end
