#import <Foundation/Foundation.h>
#import "Converter.h"


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	Converter * conv = [Converter new];
	[conv run];
    [pool drain];
    return 0;
}
