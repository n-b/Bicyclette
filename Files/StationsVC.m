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
#import "UITableViewCell+NibLoaded.h"
#import "Station.h"
#import "Region.h"
#import "StationDetailVC.h"
#import "VelibModel+Favorites.h"
#import "List.h"


/****************************************************************************/
#pragma mark Private Methods

@interface StationsVC() <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UILabel * noFavoriteLabel;

- (void) updateVisibleStations;
- (void) applicationWillTerminate:(NSNotification*) notif;
- (void) applicationDidBecomeActive:(NSNotification*) notif;
- (void) commonInit;

@property (nonatomic, strong) NSOrderedSet * stations;
@end

/****************************************************************************/
#pragma mark -

@implementation StationsVC
@synthesize tableView;
@synthesize noFavoriteLabel;
@synthesize stations;

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
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	[self performSelector:@selector(updateVisibleStations) withObject:nil afterDelay:0.5];
}
/****************************************************************************/
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	StationCell * cell = [StationCell reusableCellForTable:self.tableView];
	cell.station = [self.stations objectAtIndex:indexPath.row];
    return cell;
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
		Station * station = [self.stations objectAtIndex:indexPath.row];
		[station refresh];
	}	
}

/****************************************************************************/
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.navigationController pushViewController:[StationDetailVC detailVCWithStation:[self.stations objectAtIndex:indexPath.row] inOrderedSet:self.stations] animated:YES];
}

@end

/****************************************************************************/
#pragma mark FavoriteStationsVC
/****************************************************************************/

@interface FavoriteStationsVC()
- (void) refreshLabelAnimated:(BOOL)animated;
- (void) favoriteDidChange:(NSNotification*) notif;
@end

@implementation FavoriteStationsVC

- (void) commonInit
{
	[super commonInit];
	self.title = NSLocalizedString(@"Favoris",@"");
    
    // Observe favorites changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteDidChange:) name:VelibModelNotifications.favoriteChanged object:nil];

    self.stations = BicycletteAppDelegate.model.mainBookmarksList.stations;
}


- (void) favoriteDidChange:(NSNotification*) notif
{
    NSOrderedSet * oldStations = self.stations;
    self.stations = BicycletteAppDelegate.model.mainBookmarksList.stations;
	if ([notif.object isFavorite])
	{
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.stations indexOfObject:notif.object] inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
	}
    else
    {
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[oldStations indexOfObject:notif.object] inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self refreshLabelAnimated:YES];
}

/****************************************************************************/
#pragma mark No Favorite Label

- (void) refreshLabelAnimated:(BOOL)animated
{
	self.noFavoriteLabel.hidden = NO;
	if(animated)
		[UIView beginAnimations:nil context:NULL];
	BOOL hasNoFavorite = self.stations.count==0;
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
    [BicycletteAppDelegate.model.mainBookmarksList.bookmarksSet moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndexPath.row]
                                                                             toIndex:toIndexPath.row];
}

@end

/****************************************************************************/
#pragma mark RegionStationsVC
/****************************************************************************/
@interface RegionStationsVC()
@property (nonatomic, strong) Region * region;
@end

@implementation RegionStationsVC : StationsVC
@synthesize region;
+ (id) stationsVCWithRegion:(Region*)aregion
{
	return [[self alloc] initWithRegion:aregion];
}

- (id) initWithRegion:(Region*)aregion
{
	self = [super initWithNibName:nil bundle:nil];
	if (self != nil) 
	{
		self.region = aregion;
		self.title = self.region.name;
		
        self.stations = self.region.stations;
	}
	return self;
}


@end
