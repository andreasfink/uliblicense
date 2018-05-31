//
//  main.m
//  mminfo
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011-2018 Andreas Fink. All rights reserved.
//

#include <stdio.h>
#include "common.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "../version.h"


#define DICT_SET_STRING(dict,name,s1) \
{ \
    NSString *s = s1; \
    if(s.length > 0) \
    { \
        dict[name] = s; \
    }\
}

#define DICT_SET_ARRAY(dict,name,a1) \
{ \
    NSArray *a = a1;\
    if(a.count > 0) \
    { \
        dict[name] = a; \
    }\
}

int main (int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString *line = [NSString stringWithFormat:@"mminfo " VERSION "\nSerial Number: %@",GetMachineSerialNumber()];
        fprintf(stdout,"\n%s\n",[line UTF8String]);
        
        UMSynchronizedSortedDictionary  *dict =  [[UMSynchronizedSortedDictionary alloc]init];

        DICT_SET_STRING(dict,@"hostname",[UMUtil hostname])
        DICT_SET_ARRAY(dict,@"interfaces",[UMUtil getMacAddrs])
        DICT_SET_STRING(dict,@"serial",[UMUtil getMachineSerialNumber])
        DICT_SET_STRING(dict,@"uuid",[UMUtil getMachineUUID])
        DICT_SET_STRING(dict,@"cpu-serials",[UMUtil getCPUSerialNumbers])
        NSString *s = [dict jsonString];
        fprintf(stdout,"%s\n",s.UTF8String);
        fflush(stdout);
    }
    return 0;
}
