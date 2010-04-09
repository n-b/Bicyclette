//
//  StationCell.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABTableViewCell.h"

@interface StationCell : ABTableViewCell {
	NSDictionary *	station;
	NSDictionary *	stationInfo;
	BOOL			isFavorite;
}

+ (id) reusableCellForTable:(UITableView*)table;

@property (nonatomic,retain) NSDictionary * station;
@property (nonatomic,retain) NSDictionary * stationInfo;
@property (nonatomic) BOOL isFavorite;
@end
