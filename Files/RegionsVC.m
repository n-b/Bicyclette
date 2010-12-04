//
//  RegionsVC.m
//  Bicyclette
//
//  Created by Nicolas on 01/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "RegionsVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "RegionCell.h"
#import "UITableViewCell+EasyReuse.h"
#import "Region.h"
#import "StationsVC.h"

/****************************************************************************/
#pragma mark Private Methods

@interface RegionsVC()
@property (nonatomic, retain) NSFetchedResultsController *frc;
@end

/****************************************************************************/
#pragma mark -

@implementation RegionsVC
@synthesize frc;

- (void) awakeFromNib
{
	NSFetchRequest * regionsRequest = [[NSFetchRequest new] autorelease];
	[regionsRequest setEntity:[Region entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	[regionsRequest setSortDescriptors:[NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],nil]];
	self.frc = [[[NSFetchedResultsController alloc]
				 initWithFetchRequest:regionsRequest
				 managedObjectContext:BicycletteAppDelegate.dataManager.moc
				 sectionNameKeyPath:nil
				 cacheName:nil] autorelease];
}

- (void) dealloc
{
	self.frc = nil;
	[super dealloc];
}


/****************************************************************************/
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0); // Setting not honored in the xib
	self.tableView.backgroundColor = [UIColor clearColor];
	
	NSError * fetchError = nil;
	[self.frc performFetch:&fetchError];
	if(fetchError)
		NSLog(@"fetchError : %@",fetchError);
}


/****************************************************************************/
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.frc.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.frc.sections objectAtIndex:(NSUInteger)section];
    return (NSInteger)[sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RegionCell * cell = [RegionCell reusableCellForTable:self.tableView];
	cell.region = [self.frc objectAtIndexPath:indexPath];
    return cell;
}


/****************************************************************************/
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[RegionStationsVC stationsVCWithRegion:[self.frc objectAtIndexPath:indexPath]] animated:YES];
}

@end

