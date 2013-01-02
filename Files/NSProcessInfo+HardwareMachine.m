//
//  NSProcessInfo+HardwareMachine.m
//  Bicyclette
//
//  Created by Nicolas on 02/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#import "NSProcessInfo+HardwareMachine.h"
#include <sys/sysctl.h>

@implementation NSProcessInfo (HardwareMachine)

- (NSString*) hardwareMachine
{
#if TARGET_IPHONE_SIMULATOR
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"iPad Simulator";
    } else {
        return @"iPhone Simulator";
    }
#endif
    size_t len = 0;
    sysctlbyname("hw.machine", NULL, &len, NULL, 0);
    if (len) {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.machine", model, &len, NULL, 0);
        NSString * result = [[NSString alloc] initWithCString:model encoding:NSASCIIStringEncoding];
        free(model);
        return result;
    }
    return nil;
}

@end
