//
//  BicycletteBar.h
//  Bicyclette
//
//  Created by Nicolas on 10/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BicycletteBarDelegate;

@interface BicycletteBar : UIToolbar
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, assign) IBOutlet id<BicycletteBarDelegate> delegate;
@end


@protocol BicycletteBarDelegate
- (void) bicycletteBar:(BicycletteBar*)bar didSelectIndex:(NSUInteger)index;
@end


