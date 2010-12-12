//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "Station.h"

@implementation MapVC

@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSFetchRequest * allRequest = [[NSFetchRequest new] autorelease];
	[allRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	
	[self.mapView addAnnotations:[BicycletteAppDelegate.dataManager.moc executeFetchRequest:allRequest error:NULL]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
