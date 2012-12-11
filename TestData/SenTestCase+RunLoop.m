//
//  SenTestCase+RunLoop.m
//
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Nicolas Bouilleaud. All rights reserved.
//

#import "SenTestCase+RunLoop.h"

@implementation SenTestCase (RunLoop)

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs flag:(BOOL*)completed {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (completed==NULL || !(*completed));
    
    return completed!=NULL && (*completed);
}

@end
