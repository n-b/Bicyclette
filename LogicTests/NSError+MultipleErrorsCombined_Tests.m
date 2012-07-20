//
//  BicycletteLogicTests.m
//  BicycletteLogicTests
//
//  Created by Nicolas Bouilleaud on 27/11/11.
//  Copyright (c) 2011 Visuamobile. All rights reserved.
//
#import "NSError+MultipleErrorsCombined.h"

@interface NSError_MultipleErrorsCombined_Tests : SenTestCase
@end

@implementation NSError_MultipleErrorsCombined_Tests
{
    NSError * error1, * error2, * error3, * error4, * error12, * error34;
}

- (void)setUp
{
    [super setUp];
    
    error1 = [NSError errorWithDomain:@"a" code:1 userInfo:nil];
    error2 = [NSError errorWithDomain:@"a" code:2 userInfo:nil];
    error3 = [NSError errorWithDomain:@"a" code:3 userInfo:nil];
    error4 = [NSError errorWithDomain:@"a" code:4 userInfo:nil];
    error12 = [NSError errorWithDomain:NSCocoaErrorDomain
                                 code:NSValidationMultipleErrorsError
                             userInfo:@{ NSDetailedErrorsKey : @[error1,error2] }];
    error34 = [NSError errorWithDomain:NSCocoaErrorDomain
                                  code:NSValidationMultipleErrorsError
                              userInfo:@{ NSDetailedErrorsKey : @[error3,error4] }];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testUnderlying_1
{
    STAssertTrue([error1.underlyingErrors containsObject:error1], nil);
}

- (void)testUnderlying_12
{
    STAssertTrue([error12.underlyingErrors containsObject:error1], nil);
    STAssertTrue([error12.underlyingErrors containsObject:error2], nil);
    STAssertFalse([error12.underlyingErrors containsObject:error12], nil);
}

- (void)testCreation
{
    STAssertEqualObjects([NSError errorFromOriginalError:error1 error:nil], error1, nil);
    STAssertEqualObjects([NSError errorFromOriginalError:nil error:error1], error1, nil);
}

- (void)testCombined_1_2
{
    NSError * test = [NSError errorFromOriginalError:error1 error:error2];
    STAssertTrue([test.underlyingErrors containsObject:error1], nil);
    STAssertTrue([test.underlyingErrors containsObject:error2], nil);
}

- (void)testCombined_3_12
{
    NSError * test = [NSError errorFromOriginalError:error3 error:error12];
    STAssertTrue([test.underlyingErrors containsObject:error1], nil);
    STAssertTrue([test.underlyingErrors containsObject:error2], nil);
    STAssertTrue([test.underlyingErrors containsObject:error3], nil);
}

- (void)testCombined_12_3
{
    NSError * test = [NSError errorFromOriginalError:error12 error:error3];
    STAssertTrue([test.underlyingErrors containsObject:error1], nil);
    STAssertTrue([test.underlyingErrors containsObject:error2], nil);
    STAssertTrue([test.underlyingErrors containsObject:error3], nil);
}

- (void)testComplexCombined_12_34
{
    NSError * test = [NSError errorFromOriginalError:error12 error:error34];
    STAssertTrue([test.underlyingErrors containsObject:error1], nil);
    STAssertTrue([test.underlyingErrors containsObject:error2], nil);
    STAssertTrue([test.underlyingErrors containsObject:error3], nil);
    STAssertTrue([test.underlyingErrors containsObject:error4], nil);
}


@end
