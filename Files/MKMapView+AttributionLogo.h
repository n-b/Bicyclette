//
//  MKMapView+AttributionLogo.h
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

// Hacky Category to move the Google/copyright logo from the bottom left to the top left.

@interface MKMapView (AttributionLogo)
- (void) relocateAttributionLabelIfNecessary;
@end
