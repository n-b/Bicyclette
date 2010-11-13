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

@interface StationsListViewController() <NSFetchedResultsControllerDelegate>
- (void) updateVisibleStations;

- (void) appWillTerminate:(NSNotification*) notif;
@property (nonatomic) BOOL	onlyShowFavorites;
@property (nonatomic, retain) NSFetchedResultsController *frc;
@end


@implementation StationsListViewController

@synthesize frc;
@synthesize favoritesButton, onlyShowFavorites;

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
												 name:UIApplicationWillTerminateNotification
											   object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
												 name:UIApplicationWillResignActiveNotification
											   object:[UIApplication sharedApplication]];
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.frc = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark -
#pragma mark View lifecycle

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
				cacheName:NSStringFromClass([StationsListViewController class])];
	self.frc.delegate = self;

	self.onlyShowFavorites = [[NSUserDefaults standardUserDefaults] boolForKey:@"OnlyShowFavorites"];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	CGPoint offset = self.tableView.contentOffset;
	CGFloat newOffset = [[NSUserDefaults standardUserDefaults] floatForKey:@"TableOffset"];
	if(newOffset)
		offset.y = newOffset;
	self.tableView.contentOffset = offset;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	[self updateVisibleStations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) appWillTerminate:(NSNotification*) notif
{
	[[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:@"TableOffset"];
	[[NSUserDefaults standardUserDefaults] setBool:self.onlyShowFavorites forKey:@"OnlyShowFavorites"];
}

/****************************************************************************/
#pragma mark Actions
- (IBAction) toggleFavorites
{
	self.onlyShowFavorites = !self.onlyShowFavorites;
}

- (void) setOnlyShowFavorites:(BOOL)newValue
{
	onlyShowFavorites = newValue;
	self.favoritesButton.style = self.onlyShowFavorites?UIBarButtonItemStyleDone:UIBarButtonItemStylePlain;	

	[NSFetchedResultsController deleteCacheWithName:NSStringFromClass([StationsListViewController class])];
	if(self.onlyShowFavorites)
		[self.frc.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite == YES"]];
	else
		[self.frc.fetchRequest setPredicate:nil];
	NSError * fetchError = nil;
	[self.frc performFetch:&fetchError];
	if(fetchError)
		NSLog(@"fetchError : %@",fetchError);
	[self.tableView reloadData];
}

/****************************************************************************/
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

/****************************************************************************/
#pragma mark FRC Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if(!BicycletteAppDelegate.dataManager.updatingXML)
		[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if(self.onlyShowFavorites && type==NSFetchedResultsChangeDelete)
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	if(!BicycletteAppDelegate.dataManager.updatingXML && type==NSFetchedResultsChangeUpdate)
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
	
	else if(self.onlyShowFavorites && type==NSFetchedResultsChangeDelete)
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 	if(!BicycletteAppDelegate.dataManager.updatingXML)
		[self.tableView endUpdates];
	else
	{
		[self.tableView reloadData];
		[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
	}
}


/****************************************************************************/
#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

/****************************************************************************/
#pragma mark Scroll View delegate / Stations status update

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(!decelerate)
		[self updateVisibleStations];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self updateVisibleStations];
}

- (void) updateVisibleStations
{
	for (NSIndexPath * indexPath in [self.tableView indexPathsForVisibleRows]) {
		Station * station = [self.frc objectAtIndexPath:indexPath];
		[station refresh];
	}	
}

@end

