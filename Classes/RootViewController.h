//
//  RootViewController.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	NSArray *				arrdtArray;
	NSMutableDictionary *	stationsDictionary;
	NSMutableSet *			currentRequests;
	NSMutableArray *		favoritesArray;
	BOOL					shouldCancel;
	
	UIBarButtonItem *		favoritesButton;
	BOOL					onlyShowFavorites;
	
	UISegmentedControl *				titleToggle;
}

- (IBAction) sendRequests;

- (IBAction) toggleFavorites;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * favoritesButton;

- (IBAction) toggleWanted;
@property (nonatomic,retain) IBOutlet UISegmentedControl * titleToggle;

@end
