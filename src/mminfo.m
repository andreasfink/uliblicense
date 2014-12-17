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
#include "../version.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString *line = [NSString stringWithFormat:@"mminfo " VERSION "\nSerial Number: %@",GetMachineSerialNumber()];
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
    return 0;
}
