#import "Region.h"

/****************************************************************************/
#pragma mark -

@interface Region ()
@property (readonly, nonatomic, readwrite) MKCoordinateRegion coordinateRegion;
@end

/****************************************************************************/
#pragma mark -

@implementation Region

@synthesize coordinateRegion;

- (void) setupCoordinates
{
	self.minLat = [self.stations valueForKeyPath:@"@min.lat"];
	self.maxLat = [self.stations valueForKeyPath:@"@max.lat"];
	self.minLng = [self.stations valueForKeyPath:@"@min.lng"];
	self.maxLng = [self.stations valueForKeyPath:@"@max.lng"];
}


- (NSString *) description
{
	return [NSString stringWithFormat:@"Region %@ (%@) - %d stations - de {%f,%f} à {%f,%f}",
			self.number, self.name,
			self.stations.count,
			self.minLatValue, self.minLngValue, self.maxLatValue, self.maxLngValue];
}

- (MKCoordinateRegion) coordinateRegion
{
	if(coordinateRegion.center.latitude == 0 &&
	   coordinateRegion.center.longitude == 0 &&
	   coordinateRegion.span.latitudeDelta == 0 &&
	   coordinateRegion.span.longitudeDelta == 0 )
	{
		CLLocationCoordinate2D center;
		center.latitude = ([self.minLat doubleValue] + [self.maxLat doubleValue]) / 2.0f;
		center.longitude = ([self.minLng doubleValue] + [self.maxLng doubleValue]) / 2.0f; // This is very wrong ! Do I really need a if?
		MKCoordinateSpan span;
		span.latitudeDelta = fabs([self.minLat doubleValue] - [self.maxLat doubleValue]);
		span.longitudeDelta = fabs([self.minLng doubleValue] - [self.maxLng doubleValue]);
		self.coordinateRegion = MKCoordinateRegionMake(center, span);
	}
	return coordinateRegion;
}

/****************************************************************************/
#pragma mark 

- (NSArray *) sortedStations
{
    return [self.stations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]];
}

@end
