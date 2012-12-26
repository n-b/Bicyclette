//
//  BicycletteAnnotationView.m
//  Bicyclette
//
//  Created by Nicolas on 20/07/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteAnnotationView.h"

@interface BicycletteAnnotationView ()
@property DrawingCache* drawingCache;
@end

@implementation BicycletteAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation drawingCache:(DrawingCache*)drawingCache
{
    self = [super initWithAnnotation:annotation reuseIdentifier:[[self class] reuseIdentifier]];
    self.drawingCache = drawingCache;
    return self;
}

+ (NSString*) reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    [self setNeedsDisplay];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.annotation = nil;
}

- (void) willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    // Make sure sublayers are drawn at the correct scale
    if(newWindow)
        for (CALayer * sublayer in self.layer.sublayers)
            if(sublayer.contentsScale != newWindow.screen.scale)
                sublayer.contentsScale = newWindow.screen.scale;
}

@end
