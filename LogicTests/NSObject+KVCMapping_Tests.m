//
//  NSObject+KVCMapping_Tests.m
//  Bicyclette
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Nicolas Bouilleaud. All rights reserved.
//
#import "NSObject+KVCMapping.h"
#import "FormattedStringToDateValueTransformer.h"

@interface NSObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSObject_KVCMapping_Tests
{
    NSDictionary * mapping;
}

- (void) setUp
{
    [super setUp];
    mapping = @{
    @"usedName" : @"actualName",
    @"usedDate" : @"ISO8601StringToDate:actualDate"
    };
    
    // Setup formatter and transformer
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSValueTransformer * valueTransformer = [[FormattedStringToDateValueTransformer alloc] initWithDateFormatter:dateFormatter];
    [NSValueTransformer setValueTransformer:valueTransformer forName:@"ISO8601StringToDate"];
}

- (void) testBasicMapping
{
    NSMutableDictionary * test = [NSMutableDictionary dictionary];
    [test setValue:@"testValue" forKey:@"usedName" withMappingDictionary:mapping];
    STAssertNil([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualName"], @"testValue", nil);
}

- (void) testTransformerMapping
{
    // Setup date (my birthdate)
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:372671100];

    // Test
    NSMutableDictionary * test = [NSMutableDictionary dictionary];
    [test setValue:@"1981-10-23T07:45:00Z" forKey:@"usedDate" withMappingDictionary:mapping];
    STAssertEqualObjects([test valueForKey:@"actualDate"], date, nil);
}

@end

/****************************************************************************/
#pragma mark -

@interface NSManagedObject_KVCMapping_Tests : SenTestCase
@end

@implementation NSManagedObject_KVCMapping_Tests
{
    NSManagedObjectContext * moc;
    NSDictionary * mapping;
    NSDictionary * goodDataset, * badDataSet;
}

- (void) setUp
{
    [super setUp];

    moc = [NSManagedObjectContext new];
    moc.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                      [[NSManagedObjectModel alloc] initWithContentsOfURL:
                                       [[NSBundle bundleForClass:[self class]] URLForResource:@"NSObject+KVCMapping_Tests" 
                                                                                withExtension:@"momd"]]];

    mapping = @{@"usedBoolean": @"actualBoolean",
               @"usedData": @"actualData",
               @"usedDate": @"actualDate",
               @"usedDecimal": @"actualDecimal",
               @"usedDouble": @"actualDouble",
               @"usedFloat": @"actualFloat",
               @"usedInt16": @"actualInt16",
               @"usedInt32": @"actualInt32",
               @"usedInt64": @"actualInt64",
               @"usedString": @"actualString"};

    NSDate * date = [NSDate date];
    
    goodDataset = @{@"usedBoolean": @YES,
                   @"usedInt16": [NSNumber numberWithShort:100],
                   @"usedInt32": @100,
                   @"usedInt64": @100LL,
                   @"usedDecimal": [NSDecimalNumber numberWithInt:100],
                   @"usedFloat": @100.0f,
                   @"usedDouble": @100.0,
                   @"usedString": @"100",
                   @"usedData": [@"test" dataUsingEncoding:NSUTF8StringEncoding],
                   @"usedDate": date};
    
    badDataSet = @{@"usedBoolean": @"YES",
                  @"usedInt16": @"100",
                  @"usedInt32": @"100",
                  @"usedInt64": @"100",
                  @"usedDecimal": @"100",
                  @"usedFloat": @"100",
                  @"usedDouble": @"100",
                  @"usedString": @100,
                  @"usedData": [@"test" dataUsingEncoding:NSUTF8StringEncoding],
                  @"usedDate": date};
}

- (void) testBasic
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValue:@"testValue" forKey:@"usedString" withMappingDictionary:mapping];
    STAssertThrows([test valueForKey:@"usedName"], nil);
    STAssertEqualObjects([test valueForKey:@"actualString"], @"testValue", nil);
}

- (void) testSimpleDataset
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValuesForKeysWithDictionary:goodDataset withMappingDictionary:mapping];
    
    for (NSString * wantedKey in goodDataset) {
        id value = goodDataset[wantedKey];
        NSString * realKey = mapping[wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }
}

- (void) testAutomaticCoercionDataset
{
    NSManagedObject * test = [NSEntityDescription insertNewObjectForEntityForName:@"TestEntity" inManagedObjectContext:moc];
    [test setValuesForKeysWithDictionary:badDataSet withMappingDictionary:mapping];
    
    for (NSString * wantedKey in goodDataset) {
        id value = goodDataset[wantedKey];
        NSString * realKey = mapping[wantedKey];
        STAssertEqualObjects([test valueForKey:realKey], value, nil);
    }
}

@end
