//
//  MapVC.h
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapVC : UIViewController 

// Outlets
@property (nonatomic, assign) IBOutlet MKMapView * mapView;
@property (nonatomic, assign) IBOutlet UIBarButtonItem * centerMapButton;

// Actions
- (IBAction)changeGeolocMode;
@end
