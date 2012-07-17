//
//  RadarUpdateQueue.h
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 16/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

@class VelibModel;

@interface RadarUpdateQueue : NSObject
- (id)initWithModel:(VelibModel*)model;

@property (nonatomic) CLLocation * referenceLocation;
@end
