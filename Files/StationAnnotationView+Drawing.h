//
//  StationAnnotationView+Drawing.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 24/06/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "Style.h"
#import "StationAnnotationView.h"


@interface StationAnnotationView (Drawing)
+ (CGImageRef)sharedImageWithMode:(StationAnnotationMode)mode
                  backgroundColor:(UIColor*)backgroundColor
                          starred:(BOOL)starred
                            value:(NSString*)text;
@end
