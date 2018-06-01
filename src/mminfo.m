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

#import <ulib/ulib.h>

#define DICT_ADD_STRING(dict,name,s1) \
{ \
    NSString *s = s1; \
    if(s.length > 0) \
    { \
        dict[name] = s; \
    }\
}

#define DICT_ADD_ARRAY(dict,name,a1) \
{ \
    NSArray *a = a1;\
    if(a.count > 0) \
    { \
        dict[name] = a; \
    }\
}

#define DICT_ADD_DICT(dict,name,a1) \
{ \
    NSDictionary *a = a1;\
    if(a.count > 0) \
    { \
        dict[name] = a; \
    }\
}

int main (int argc, const char * argv[])
{
    @autoreleasepool
    {
        UMSynchronizedSortedDictionary  *dict =  [[UMSynchronizedSortedDictionary alloc]init];

        DICT_ADD_STRING(dict,@"hostname",[UMHost localHostName])
        DICT_ADD_DICT(dict,@"interfaces",[UMUtil getMacAddrs])
        DICT_ADD_DICT(dict,@"ip-addresses",[UMUtil getIpAddrs])
        DICT_ADD_STRING(dict,@"serial",[UMUtil getMachineSerialNumber])
        DICT_ADD_STRING(dict,@"uuid",[UMUtil getMachineUUID])
        DICT_ADD_ARRAY(dict,@"cpu-serials",[UMUtil getCPUSerialNumbers])

        NSDictionary *appDefinition = @ {
            @"version" : @(VERSION),
            @"executable" : @"mminfo",
            @"run-as" : @(argv[0]),
            @"copyright" : @"© 2018 Andreas Fink",
        };

        NSArray *commandLineDefinition = @[
                                           @{
                                               @"name"  : @"version",
                                               @"short" : @"-V",
                                               @"long"  : @"--version",
                                               @"help"  : @"shows the software version"
                                               },
                                           @{
                                               @"name"  : @"verbose",
                                               @"short" : @"-v",
                                               @"long"  : @"--verbose",
                                               @"help"  : @"enables verbose mode"
                                               },
                                           @{
                                               @"name"  : @"help",
                                               @"short" : @"-h",
                                               @"long" : @"--help",
                                               @"help"  : @"shows the help screen",
                                               },
                                           @{
                                               @"name"  : @"request",
                                               @"short" : @"-r",
                                               @"long"  : @"--license-request",
                                               @"help"  : @"request a license from the license server for this hardware",
                                               },
                                           @{
                                               @"name"  : @"display",
                                               @"short" : @"-d",
                                               @"long"  : @"--display",
                                               @"help"  : @"displays information for the license",
                                               },
                                           @{
                                               @"name"  : @"keypair",
                                               @"long"  : @"--generate-keypair",
                                               @"help"  : @"generate a keypair for signing",
                                               },
                                           @{
                                               @"name"  : @"url",
                                               @"short" : @"-u",
                                               @"long"  : @"--license-server-url",
                                               @"argument" : @"url",
                                               @"help"  : @"sets the license server url",
                                               }];

        UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                                           appDefinition:appDefinition
                                                                                    argc:argc
                                                                                    argv:argv];
        [_commandLine handleStandardArguments];
        BOOL actionDone=NO;
        NSDictionary *params = _commandLine.params;
        NSString *url = @ "https://license.messagemover.com/request.php";
        if(params[@"url"])
        {
            id p = params[@"url"];
            if([p isKindOfClass:[NSArray class]])
            {
                url = ((NSArray *)p)[0];
            }
            else if([p isKindOfClass:[NSString class]])
            {
                url = (NSString *)p;
            }
            else
            {
                fprintf(stderr, "Error: Can't interpret url\n");
                exit(-1);
            }
        }
        if(params[@"keypair"])
        {
            NSDictionary *d = [UMCrypto generateRsaKeyPair];

            NSString *privateKey = d[@"private-key"];
            NSString *publicKey = d[@"public-key"];

            fprintf(stdout,"\n%s\n%s\n",privateKey.UTF8String,publicKey.UTF8String);
            fflush(stdout);
            exit(0);
        }

        if(params[@"display"])
        {
            NSString *s = [dict jsonString];
            fprintf(stdout,"%s",s.UTF8String);
            actionDone = YES;
        }
        if(params[@"request"])
        {
            NSString *request = [[dict jsonString] urlencode];
            NSString *full_url = [NSString stringWithFormat:@"%@?request=%@",url,request];
            UMHTTPClientRequest *creq = [[UMHTTPClientRequest alloc]initWithURLString:full_url withChache:NO timeout:30];
            UMHTTPClient *httpClient = [[UMHTTPClient alloc]init];
            NSString *result = [httpClient simpleSynchronousRequest:creq];
            fprintf(stdout, "%s\n",result.UTF8String);
            actionDone = YES;
        }
        if(actionDone)
        {
            exit(0);
        }
    }
    return 0;
}
