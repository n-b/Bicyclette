#import "_Region.h"
#import <MapKit/MapKit.h>

@interface Region : _Region {}
- (void) setupCoordinates;

@property (readonly, nonatomic) MKCoordinateRegion coordinateRegion;

@property (weak, nonatomic, readonly) NSArray * sortedStations;

@end
