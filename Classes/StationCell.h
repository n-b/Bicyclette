//
//  StationCell.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABTableViewCell.h"

#import <CoreLocation/CoreLocation.h>

@interface StationCell : ABTableViewCell {
	NSDictionary *	station;
	NSDictionary *	stationInfo;
	BOOL			favorite;
	BOOL			loading;
	CLLocationDistance distance;
}

+ (id) reusableCellForTable:(UITableView*)table;

@property (nonatomic,retain) NSDictionary * station;
@property (nonatomic,retain) NSDictionary * stationInfo;
@property (nonatomic, getter=isFavorite) BOOL favorite;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) CLLocationDistance distance;
@end
