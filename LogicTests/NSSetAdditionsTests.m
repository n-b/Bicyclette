//
//  NSSetAdditionsTests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 17/11/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "NSSetAdditions.h"

@interface NSSetAdditionsTests : SenTestCase
@end

@implementation NSSetAdditionsTests

- (void) testAnyObjectWithValue
{
    NSSet * testdata = [NSSet setWithArray:@[
                        @{@"key" : @"v", @"id": @1},
                        @{@"key" : @"a", @"id": @2},
                        @{@"key" : @"l", @"id": @3},
                        @{@"key" : @"u", @"id": @4},
                        @{@"key" : @"e", @"id": @5},
                        ]];
    
    STAssertEqualObjects([[testdata anyObjectWithValue:@"a" forKey:@"key"] objectForKey:@"id"], @2, nil);
}

- (void) testFilteredSetWithValueForKey
{
    NSSet * testdata = [NSSet setWithArray:@[
                        @{@"key" : @"b", @"id": @1},
                        @{@"key" : @"a", @"id": @2},
                        @{@"key" : @"b", @"id": @3},
                        @{@"key" : @"a", @"id": @4},
                        @{@"key" : @"b", @"id": @5},
                        ]];
    
    NSSet * expectedResult = [NSSet setWithArray:@[
                              @{@"key" : @"b", @"id": @1},
                              @{@"key" : @"b", @"id": @3},
                              @{@"key" : @"b", @"id": @5},
                              ]];
    STAssertEqualObjects([testdata filteredSetWithValue:@"b" forKey:@"key"], expectedResult, nil);
}

@end
