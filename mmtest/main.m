//
//  main.m
//  mmtest
//
//  Created by Andreas Fink on 05.06.18.
//

#import <Foundation/Foundation.h>
#import <ulib/ulib.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool
    {
        // insert code here...
        NSLog(@"MACS:\n%@", [UMUtil getArrayOfMacAddresses]);
    }
    return 0;
}
