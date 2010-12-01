//
//  StationsVC.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationsVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "StationCell.h"
#import "UITableViewCell+EasyReuse.h"
#import "Station.h"

/****************************************************************************/
#pragma mark Private Methods

@interface StationsVC() <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
- (void) updateVisibleStations;
- (void) applicationWillTerminate:(NSNotification*) notif;
- (void) refetch;
@end

/****************************************************************************/
#pragma mark -

@implementation StationsVC
@synthesize tableView;
@synthesize frc;

/****************************************************************************/
#pragma mark Object Life Cycle

- (void) awakeFromNib
{
	// Observe app termination
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

- (void) applicationWillTerminate:(NSNotification*) notif
{
	[[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:[NSString stringWithFormat:@"TableOffsetFor%@",[self class]]];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.frc = nil;
	[super dealloc];
}

/****************************************************************************/
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = StationCellHeight;
	self.tableView.backgroundColor = [UIColor lightGrayColor];
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	UIEdgeInsets insets = self.tableView.contentInset;
	insets.top += self.navigationController.navigationBar.frame.size.height;
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset = insets;
	
	NSNumber * offset = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"TableOffsetFor%@",[self class]]];
	if(offset) self.tableView.contentOffset = CGPointMake(0, [offset floatValue]);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
}

/****************************************************************************/
#pragma mark frc

- (void) setFrc:(NSFetchedResultsController*)newValue
{
	if(![frc isEqual:newValue])
	{
		[frc autorelease];
		frc = [newValue retain];
		self.frc.delegate = self;		
	}
}

- (void) refetch
{
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
	StationCell * cell = [StationCell reusableCellForTable:self.tableView];
	cell.station = [self.frc objectAtIndexPath:indexPath];
    return cell;
}

/****************************************************************************/
#pragma mark frc Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)afrc
{
 	if(BicycletteAppDelegate.dataManager.updatingXML)
	{
		self.editing = NO;
		[self.tableView reloadData];
		[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
	}
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
		Station * station = [self.frc objectAtIndexPath:indexPath];
		[station refresh];
	}	
}

@end

/****************************************************************************/
#pragma mark FavoriteStationsVC
/****************************************************************************/

@interface FavoriteStationsVC()
@property BOOL reordering;
@end

@implementation FavoriteStationsVC
@synthesize reordering;

- (void) awakeFromNib
{
	[super awakeFromNib];
	self.title = NSLocalizedString(@"Favoris",@"");

	NSFetchRequest * favoritesRequest = [[NSFetchRequest new] autorelease];
	[favoritesRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	[favoritesRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite_index != -1"]];
	[favoritesRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"favorite_index" ascending:YES] autorelease]]];
	self.frc = [[NSFetchedResultsController alloc]
				initWithFetchRequest:favoritesRequest
				managedObjectContext:BicycletteAppDelegate.dataManager.moc
				sectionNameKeyPath:nil
				cacheName:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return nil;
}

/****************************************************************************/
#pragma mark frc Delegate

- (void)controller:(NSFetchedResultsController *)frc didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if(BicycletteAppDelegate.dataManager.updatingXML) return;
	
	if (type == NSFetchedResultsChangeDelete)
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

/****************************************************************************/
#pragma mark Favorites editing

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setEditing:NO animated:NO];
	[self refetch];
	[self.tableView reloadData];
	self.tableView.hidden = self.frc.fetchedObjects.count==0;
}

- (UINavigationItem *) navigationItem
{
	UINavigationItem * item = [super navigationItem];
	item.rightBarButtonItem = self.editButtonItem;
	return item;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Station * station = [self.frc objectAtIndexPath:indexPath];
		station.favorite = NO;
	}   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	self.reordering = YES;
	NSLog(@"end move %@ to %@",fromIndexPath, toIndexPath);
	
	NSMutableArray *favorites = [NSMutableArray arrayWithArray:self.frc.fetchedObjects];
	Station* stationToMove = [favorites objectAtIndex:fromIndexPath.row];
	[favorites removeObjectAtIndex:fromIndexPath.row];
	[favorites insertObject:stationToMove atIndex:toIndexPath.row];
	
	for (NSUInteger i=0; i<[favorites count]; i++)
	{
		Station* station = [favorites objectAtIndex:i];
		if(station.favorite_indexValue!=(NSInteger)i+1)
			station.favorite_indexValue = (NSInteger)i+1;
	}
	self.reordering = NO;
	
	[BicycletteAppDelegate.dataManager performSelector:@selector(save) withObject:nil afterDelay:0];
}

@end

/****************************************************************************/
#pragma mark AllStationsVC
/****************************************************************************/

@implementation AllStationsVC : StationsVC
- (void) awakeFromNib
{
	[super awakeFromNib];
	self.title = NSLocalizedString(@"Vélib",@"");

	NSFetchRequest * allRequest = [[NSFetchRequest new] autorelease];
	[allRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
	[allRequest setSortDescriptors:[NSArray arrayWithObjects:
									[[[NSSortDescriptor alloc] initWithKey:@"code_postal" ascending:YES] autorelease],
									[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
									nil]];
	self.frc = [[NSFetchedResultsController alloc]
				initWithFetchRequest:allRequest
				managedObjectContext:BicycletteAppDelegate.dataManager.moc
				sectionNameKeyPath:@"code_postal"
				cacheName:@"velib_sections_cache"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel * sectionTitle = [UILabel viewFromNibNamed:@"SectionHeader"];
	sectionTitle.text = [[self.frc.sections objectAtIndex:(NSUInteger)section] name];
	return sectionTitle;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self refetch];
}
@end
