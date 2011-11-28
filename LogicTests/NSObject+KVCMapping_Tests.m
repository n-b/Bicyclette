//
//  NSObject+KVCMapping_Tests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import "NSObject+KVCMapping.h"

@interface NSObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSObject_KVCMapping_Tests
{
    NSDictionary * mapping;
}

- (void) setUp
{
    [super setUp];
    
    mapping = [NSDictionary dictionaryWithObject:@"actualName" forKey:@"usedName"];
}

// All code under test is in the iOS Application
- (void)testAppDelegate
{
    NSMutableDictionary * test = [NSMutableDictionary dictionary];
    [test setValue:@"testValue" forKey:@"usedName" withMappingDictionary:mapping];
    STAssertNil([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualName"], @"testValue", nil);
    NSManagedObject
}

@end

