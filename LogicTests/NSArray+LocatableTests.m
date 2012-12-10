//
//  NSArray+LocatableTests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 17/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSArray+Locatable.h"

@interface NSArrayLocatableTests : SenTestCase
@end

@implementation NSDictionary (Locatable)
- (id) location
{
    return [self objectForKey:@"location"];
}
@end

@implementation NSArrayLocatableTests

- (void) testFilteredArray
{
    NSArray * testdata = @[
                           @{@"id": @1, @"location": [[CLLocation alloc] initWithLatitude:45 longitude:2]},
                           @{@"id": @2, @"location": [[CLLocation alloc] initWithLatitude:46 longitude:3]},
                           @{@"id": @3, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2.2]},
                           @{@"id": @4, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2]},
                           @{@"id": @5, @"location": [[CLLocation alloc] initWithLatitude:47 longitude:2]},
                           ];
    
    id result = [testdata filteredArrayWithinDistance:100000 fromLocation:[[CLLocation alloc] initWithLatitude:47 longitude:2]];
    
    STAssertEqualObjects([result valueForKeyPath:@"id"], (@[@3, @4, @5]), nil);
}

- (void) testSortedArray
{
    NSArray * testdata = @[
                           @{@"id": @1, @"location": [[CLLocation alloc] initWithLatitude:45 longitude:2]},
                           @{@"id": @2, @"location": [[CLLocation alloc] initWithLatitude:46 longitude:3]},
                           @{@"id": @3, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2.2]},
                           @{@"id": @4, @"location": [[CLLocation alloc] initWithLatitude:47.2 longitude:2]},
                           @{@"id": @5, @"location": [[CLLocation alloc] initWithLatitude:47 longitude:2]},
                           ];
    
    id result = [testdata sortedArrayByDistanceFromLocation:[[CLLocation alloc] initWithLatitude:47 longitude:2]];
    STAssertEqualObjects([result valueForKeyPath:@"id"], (@[@5, @4, @3, @2, @1]), nil);
}

@end
