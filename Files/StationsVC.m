//
//  StationsVC.m
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "StationsVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibModel.h"
#import "StationCell.h"
#import "UITableViewCell+EasyReuse.h"
#import "Station.h"
#import "Region.h"
#import "StationDetailVC.h"

/****************************************************************************/
#pragma mark Private Methods

@interface StationsVC() <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
- (void) updateVisibleStations;
- (void) applicationWillTerminate:(NSNotification*) notif;
- (void) applicationDidBecomeActive:(NSNotification*) notif;
- (void) refetch;
- (void) commonInit;
@end

/****************************************************************************/
#pragma mark -

@implementation StationsVC
@synthesize tableView;
@synthesize noFavoriteLabel;
@synthesize frc;

/****************************************************************************/
#pragma mark Object Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"StationsVC" bundle:nibBundleOrNil];
	if (self != nil) 
		[self commonInit];
	return self;
}

- (void) awakeFromNib
{
	[self commonInit];
}

- (void) commonInit
{
	// Observe app termination
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
	self.wantsFullScreenLayout = YES;
}

- (void) applicationWillTerminate:(NSNotification*) notif
{
	[[NSUserDefaults standardUserDefaults] setFloat:self.tableView.contentOffset.y forKey:[NSString stringWithFormat:@"TableOffsetFor%@",[self class]]];
}

- (void) applicationDidBecomeActive:(NSNotification*) notif
{
	[self updateVisibleStations];
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
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	UIEdgeInsets insets = self.tableView.contentInset;
	insets.top += self.navigationController.navigationBar.frame.size.height;
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset = insets;
	
	NSNumber * offset = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"TableOffsetFor%@",[self class]]];
	if(offset) self.tableView.contentOffset = CGPointMake(0, [offset floatValue]);

	[self refetch];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return nil;
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
 	if(BicycletteAppDelegate.model.updatingXML)
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

/****************************************************************************/
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.navigationController pushViewController:[StationDetailVC detailVCWithStation:[self.frc objectAtIndexPath:indexPath] inArray:self.frc.fetchedObjects] animated:YES];
}

@end

/****************************************************************************/
#pragma mark FavoriteStationsVC
/****************************************************************************/

@interface FavoriteStationsVC()
- (void) refreshLabelAnimated:(BOOL)animated;
@end

@implementation FavoriteStationsVC

- (void) commonInit
{
	[super commonInit];
	self.title = NSLocalizedString(@"Favoris",@"");

	NSFetchRequest * favoritesRequest = [[NSFetchRequest new] autorelease];
	[favoritesRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
	[favoritesRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite_index != -1"]];
	[favoritesRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"favorite_index" ascending:YES] autorelease]]];
	self.frc = [[[NSFetchedResultsController alloc]
				 initWithFetchRequest:favoritesRequest
				 managedObjectContext:BicycletteAppDelegate.model.moc
				 sectionNameKeyPath:nil
				 cacheName:nil] autorelease];
}

/****************************************************************************/
#pragma mark frc Delegate

- (void)controller:(NSFetchedResultsController *)frc didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if(self.view.window==nil) return;
	if(BicycletteAppDelegate.model.updatingXML) return;
	
	if (type == NSFetchedResultsChangeDelete)
	{
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self refreshLabelAnimated:YES];
	}
}

/****************************************************************************/
#pragma mark No Favorite Label

- (void) refreshLabelAnimated:(BOOL)animated
{
	self.noFavoriteLabel.hidden = NO;
	if(animated)
		[UIView beginAnimations:nil context:NULL];
	BOOL hasNoFavorite = self.frc.fetchedObjects.count==0;
	self.noFavoriteLabel.alpha = hasNoFavorite;
	self.tableView.alpha = !hasNoFavorite;
	if(animated)
		[UIView commitAnimations];
}

/****************************************************************************/
#pragma mark Favorites editing

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self refetch];
	[self.tableView reloadData];
	[self refreshLabelAnimated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
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

	[BicycletteAppDelegate.model performSelector:@selector(save) withObject:nil afterDelay:0];
}

@end

/****************************************************************************/
#pragma mark AllStationsVC
/****************************************************************************/

@implementation AllStationsVC : StationsVC
- (void) commonInit
{
	[super commonInit];
	self.title = NSLocalizedString(@"Vélib",@"");

	NSFetchRequest * allRequest = [[NSFetchRequest new] autorelease];
	[allRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
	[allRequest setSortDescriptors:[NSArray arrayWithObjects:
									[[[NSSortDescriptor alloc] initWithKey:@"region.name" ascending:YES] autorelease],
									[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
									nil]];
	self.frc = [[[NSFetchedResultsController alloc]
				 initWithFetchRequest:allRequest
				 managedObjectContext:BicycletteAppDelegate.model.moc
				 sectionNameKeyPath:@"region.name"
				 cacheName:@"velib_sections_cache"] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.frc.sections.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel * sectionTitle = [UILabel viewFromNibNamed:@"SectionHeader"];
	sectionTitle.text = [[self.frc.sections objectAtIndex:(NSUInteger)section] number];
	return sectionTitle;
}

@end

/****************************************************************************/
#pragma mark RegionStationsVC
/****************************************************************************/
@interface RegionStationsVC()
@property (nonatomic, retain) Region * region;
@end

@implementation RegionStationsVC : StationsVC
@synthesize region;
+ (id) stationsVCWithRegion:(Region*)aregion
{
	return [[[self alloc] initWithRegion:aregion] autorelease];
}

- (id) initWithRegion:(Region*)aregion
{
	self = [super initWithNibName:nil bundle:nil];
	if (self != nil) 
	{
		self.region = aregion;
		self.title = self.region.name;
		
		NSFetchRequest * regionStationsRequest = [[NSFetchRequest new] autorelease];
		[regionStationsRequest setEntity:[Station entityInManagedObjectContext:BicycletteAppDelegate.model.moc]];
		[regionStationsRequest setPredicate:[NSPredicate predicateWithFormat:@"region == %@",self.region]];
		[regionStationsRequest setSortDescriptors:[NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],nil]];
		self.frc = [[[NSFetchedResultsController alloc]
					 initWithFetchRequest:regionStationsRequest
					 managedObjectContext:BicycletteAppDelegate.model.moc
					 sectionNameKeyPath:nil
					 cacheName:nil] autorelease];
	}
	return self;
}

- (void) dealloc
{
	self.region = nil;
	[super dealloc];
}

@end
