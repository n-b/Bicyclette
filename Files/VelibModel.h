//
//  Velib.h
//  Bicyclette
//
//  Created by Nicolas on 09/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteDataManager.h"

#import <MapKit/MapKit.h>

#define kVelibStationsStatusURL		@"http://www.velib.paris.fr/service/stationdetails/"

/****************************************************************************/
#pragma mark -

@class Station;

@interface VelibModel : BicycletteDataManager

@property (readonly) BOOL updatingXML;


@property (readonly, nonatomic) MKCoordinateRegion coordinateRegion;
@end

