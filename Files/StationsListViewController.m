//
//  StationsListViewController.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationsListViewController.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "StationCell.h"
#import "UITableViewCell+EasyReuse.h"
#import "Station.h"
#import "Section.h"

@interface StationsListViewController() <NSFetchedResultsControllerDelegate>
- (void) stationUpdated:(NSNotification*) notif;
@property (nonatomic, retain) NSFetchedResultsController *frc;
@end


@implementation StationsListViewController

@synthesize frc;

- (void) dealloc
{
	self.frc = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 90;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	self.frc = [[NSFetchedResultsController alloc]
				initWithFetchRequest:BicycletteAppDelegate.dataManager.stations
				managedObjectContext:BicycletteAppDelegate.dataManager.moc
				sectionNameKeyPath:@"code_postal"
				cacheName:@"stations_cache"];
	
	[self.frc performFetch:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationUpdated:) name:@"StationUpdated" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"StationUpdated" object:nil];
}
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.frc.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.frc.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	StationCell * cell = [StationCell reusableCellForTable:tableView];
	cell.station = [self.frc objectAtIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel * sectionTitle = [UILabel viewFromNibNamed:@"SectionHeader"];
	sectionTitle.text = [[self.frc.sections objectAtIndex:section] name];
	return sectionTitle;
}

//----

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	for (NSIndexPath * indexPath in [self.tableView indexPathsForVisibleRows]) {
		Station * station = [self.frc objectAtIndexPath:indexPath];
		[station refresh];
	}	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(!decelerate)
	{
		for (NSIndexPath * indexPath in [self.tableView indexPathsForVisibleRows]) {
			Station * station = [self.frc objectAtIndexPath:indexPath];
			[station refresh];
		}
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (void) stationUpdated:(NSNotification*) notif
{
	Station * station = [notif object];
	NSIndexPath * indexPath = [self.frc indexPathForObject:station];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationFade];
}

@end

