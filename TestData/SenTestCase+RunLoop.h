//
//  SenTestCase+RunLoop.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SenTestCase (RunLoop)

// Asynchronous Unit Tests :
// Runs the runloop until timeoutSecs seconds elapse or the completed flag is set.
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs flag:(BOOL*)completed;
@end
