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

/****************************************************************************/
#pragma mark Private Methods

@interface StationsListViewController() <NSFetchedResultsControllerDelegate>
- (void) updateVisibleStations;
- (void) appWillTerminate:(NSNotification*) notif;
@property (nonatomic) BOOL	onlyShowFavorites;
@property (nonatomic, retain) NSFetchedResultsController *allFrc;
@property (nonatomic, retain) NSFetchedResultsController *favoritesFrc;
@property (nonatomic, readonly) NSFetchedResultsController *currentFrc;
- (void) refetch;

@property BOOL reordering;

@end

/****************************************************************************/
#pragma mark -

@implementation StationsListViewController

@synthesize allFrc, favoritesFrc, onlyShowFavorites;
@synthesize favoritesButton;
@synthesize reordering;

/****************************************************************************/
#pragma mark Object Life Cycle

- (void) awakeFromNib
{
	// create frcs
	NSFetchRequest * allRequest = [[NSFetchRequest new] autorelease];
	[allRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	[allRequest setSortDescriptors:[NSArray arrayWithObjects:
									[[[NSSortDescriptor alloc] initWithKey:@"code_postal" ascending:YES] autorelease],
									[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
									nil]];
	self.allFrc = [[NSFetchedResultsController alloc]
				   initWithFetchRequest:allRequest
				   managedObjectContext:BicycletteAppDelegate.dataManager.moc
				   sectionNameKeyPath:@"code_postal"
				   cacheName:@"velib_sections_cache"];
	self.allFrc.delegate = self;		

	NSFetchRequest * favoritesRequest = [[NSFetchRequest new] autorelease];
	[favoritesRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	[favoritesRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite_index != -1"]];
	[favoritesRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"favorite_index" ascending:YES] autorelease]]];
	self.favoritesFrc = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:favoritesRequest
						 managedObjectContext:BicycletteAppDelegate.dataManager.moc
						 sectionNameKeyPath:nil
						 cacheName:nil];
	self.favoritesFrc.delegate = self;		
	
	// Observe app termination
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
												 name:UIApplicationWillTerminateNotification
											   object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
												 name:UIApplicationWillResignActiveNotification
											   object:[UIApplication sharedApplication]];
	
}

- (void) appWillTerminate:(NSNotification*) notif
{
	[[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:@"TableOffset"];
	[[NSUserDefaults standardUserDefaults] setBool:self.onlyShowFavorites forKey:@"OnlyShowFavorites"];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.allFrc = nil;
	self.favoritesFrc = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = 90;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.onlyShowFavorites = [[NSUserDefaults standardUserDefaults] boolForKey:@"OnlyShowFavorites"];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSNumber * offset = [[NSUserDefaults standardUserDefaults] objectForKey:@"TableOffset"];
	if(offset) self.tableView.contentOffset = CGPointMake(0, [offset floatValue]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	[self updateVisibleStations];
}

/****************************************************************************/
#pragma mark Actions

- (IBAction) toggleFavorites
{
	self.onlyShowFavorites = !self.onlyShowFavorites;
	[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
}

- (void) setOnlyShowFavorites:(BOOL)newValue
{
	onlyShowFavorites = newValue;
	// Change buttons styles
	self.favoritesButton.style = self.onlyShowFavorites?UIBarButtonItemStyleDone:UIBarButtonItemStyleBordered;	
	self.editButtonItem.enabled = self.onlyShowFavorites;
	if(!self.onlyShowFavorites && self.editing)
		[self setEditing:NO animated:YES];

	[self refetch];
	NSLog(@"reload data, big bad");
	[self.tableView reloadData];
}

- (NSFetchedResultsController*) currentFrc
{
	return self.onlyShowFavorites?self.favoritesFrc:self.allFrc;
}

- (void) refetch
{
	NSError * fetchError = nil;
	[self.currentFrc performFetch:&fetchError];
	if(fetchError)
		NSLog(@"fetchError : %@",fetchError);
}

/****************************************************************************/
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.currentFrc.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.currentFrc.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	StationCell * cell = [StationCell reusableCellForTable:tableView];
	cell.station = [self.currentFrc objectAtIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(self.onlyShowFavorites)
		return nil;
	
	UILabel * sectionTitle = [UILabel viewFromNibNamed:@"SectionHeader"];
	sectionTitle.text = [[self.currentFrc.sections objectAtIndex:section] name];
	return sectionTitle;
}

/****************************************************************************/
#pragma mark FRC Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//	if(controller!=self.currentFrc) return;
//	if(!BicycletteAppDelegate.dataManager.updatingXML && !self.editing)
//		[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if(controller!=self.currentFrc) return;
	
	// Generic update
	
	switch (type) {
		case NSFetchedResultsChangeUpdate:
			NSLog(@"up %@",indexPath);
//			if(!BicycletteAppDelegate.dataManager.updatingXML && !self.editing)
//				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//									  withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			NSAssert(self.onlyShowFavorites,@"wrong!");
			NSLog(@"del %@",indexPath);
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeMove:
			NSLog(@"from %@ to %@",indexPath,newIndexPath);
            break;
		case NSFetchedResultsChangeInsert:
			NSLog(@"ins %@",indexPath);
			break;
		default:
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)frc
{
	if(frc!=self.currentFrc) return;
 	if(BicycletteAppDelegate.dataManager.updatingXML)
	{
		self.editing = NO;
		[self.tableView reloadData];
		[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
	}
}


/****************************************************************************/
#pragma mark Favorites editing

- (UINavigationItem *) navigationItem
{
	UINavigationItem * item = [super navigationItem];
	item.rightBarButtonItem = self.editButtonItem;
	return item;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.onlyShowFavorites;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Station * station = [self.currentFrc objectAtIndexPath:indexPath];
		station.favorite = NO;
	}   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.onlyShowFavorites;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	self.reordering = YES;
	NSAssert(self.onlyShowFavorites,@"wrong");
	NSLog(@"end move %@ to %@",fromIndexPath, toIndexPath);

	NSMutableArray *favorites = [NSMutableArray arrayWithArray:[self.currentFrc fetchedObjects]];
	Station* stationToMove = [favorites objectAtIndex:fromIndexPath.row];
	[favorites removeObjectAtIndex:fromIndexPath.row];
	[favorites insertObject:stationToMove atIndex:toIndexPath.row];
	
	for (int i=0; i<[favorites count]; i++)
	{
		Station* station = [favorites objectAtIndex:i];
		if(station.favorite_indexValue!=i+1)
			station.favorite_indexValue = i+1;
	}
	self.reordering = NO;

	//[self refetch];
	[BicycletteAppDelegate.dataManager performSelector:@selector(save) withObject:nil afterDelay:0];
}

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
		Station * station = [self.currentFrc objectAtIndexPath:indexPath];
		[station refresh];
	}	
}

@end

