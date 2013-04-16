//
//  MKCoordinateRegion-Mac.h
//  Bicyclette
//
//  Created by Nicolas on 16/04/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#if ! TARGET_OS_IPHONE

typedef struct {
    CLLocationDegrees latitudeDelta;
    CLLocationDegrees longitudeDelta;
} MKCoordinateSpan;

typedef struct {
	CLLocationCoordinate2D center;
	MKCoordinateSpan span;
} MKCoordinateRegion;

#endif
