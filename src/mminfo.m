//
//  main.m
//  mminfo
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include "common.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int main (int argc, const char * argv[])
{
<<<<<<< HEAD
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

    NSString *line = [NSString stringWithFormat:@"mminfo 1.0\nSerial Number: %@",GetMachineSerialNumber()];
    fprintf(stdout,"\n%s\n",[line UTF8String]);

    NSDictionary *dict = GetMACAddresses();
	for(NSString *ifname in dict)
    {
        NSString *macaddr = [dict objectForKey:ifname];
        NSString *line = [NSString stringWithFormat:@"%@: %@",ifname,macaddr];
        fprintf(stdout,"%s\n",[line UTF8String]);
    }
    
    fprintf(stdout,"\n");
    fflush(stdout);
    [pool drain];
=======
    @autoreleasepool
    {
        NSString *line = [NSString stringWithFormat:@"mminfo 1.0\nSerial Number: %@",GetMachineSerialNumber()];
        fprintf(stdout,"\n%s\n",[line UTF8String]);
        
        NSDictionary *dict = GetMACAddresses();
        for(NSString *ifname in dict)
        {
            NSString *macaddr = [dict objectForKey:ifname];
            NSString *line = [NSString stringWithFormat:@"%@: %@",ifname,macaddr];
            fprintf(stdout,"%s\n",[line UTF8String]);
        }
        
        fprintf(stdout,"\n");
        fflush(stdout);
    }
>>>>>>> 7648bdfc48cdfe42d265e8beca80ea6ec88cc162
    return 0;
}



