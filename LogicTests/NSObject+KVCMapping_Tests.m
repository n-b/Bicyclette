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
}

@end

@interface NSManagedObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCMapping_Tests
{
    NSDictionary * mapping;
    NSDictionary * dataset;
    NSManagedObjectContext * moc;
}

- (void) setUp
{
    [super setUp];
    mapping = [NSDictionary dictionaryWithObjectsAndKeys:
               @"actualBoolean", @"usedBoolean",
               @"actualData", @"usedData",
               @"actualDate", @"usedDate",
               @"actualDecimal", @"usedDecimal",
               @"actualDouble", @"usedDouble",
               @"actualFloat", @"usedFloat",
               @"actualInt16", @"usedInt16",
               @"actualInt32", @"usedInt32",
               @"actualInt64", @"usedInt64",
               @"actualString", @"usedString",
               nil];
    
    dataset = [NSDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithBool:YES], @"usedBoolean",
               [@"test" dataUsingEncoding:NSUTF8StringEncoding], @"usedData",
               [NSDate date], @"usedDate",
               [NSDecimalNumber numberWithInt:100], @"usedDecimal",
               [NSNumber numberWithDouble:100], @"usedDouble",
               [NSNumber numberWithFloat:100], @"usedFloat",
               [NSNumber numberWithShort:100], @"usedInt16",
               [NSNumber numberWithInt:100], @"usedInt32",
               [NSNumber numberWithLongLong:100], @"usedInt64",
               @"string", @"usedString",
               nil];
    
    moc = [NSManagedObjectContext new];
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                      [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                       [[NSBundle bundleForClass:[self class]] URLForResource:@"NSObject+KVCMapping_Tests" 
                                                                                withExtension:@"momd"]]];
}

- (void) testBasic
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValue:@"testValue" forKey:@"usedString" withMappingDictionary:mapping];
    STAssertThrows([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualString"], @"testValue", nil);
}

- (void) testDataSet1
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValuesForKeysWithDictionary:dataset withMappingDictionary:mapping];
    STAssertEqualObjects([test valueForKey:@"actualString"], @"string", nil);
    STAssertEqualObjects([test valueForKey:@"actualBoolean"], [NSNumber numberWithBool:YES], nil);
    STAssertEqualObjects([test valueForKey:@"actualDate"], [dataset objectForKey:@"usedDate"], nil);
}

@end
