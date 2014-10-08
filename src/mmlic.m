//
//  mmlic.m
//  mmlic
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011 Andreas Fink. All rights reserved.
//

#include <time.h>
#include <sys/time.h>
#include <locale.h>

#import <Foundation/Foundation.h>
#ifndef	LINUX
#import <CoreFoundation/CoreFoundation.h>
#endif

#include "common.h"
#include <string.h>


#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int main (int argc, const char * argv[])
{
    printf("mmlic version 1.1\n");
    
    struct stat statbuf;
    if(stat("/etc/messagemover",&statbuf)!=0)
        mkdir("/etc/messagemover",0644);
    

    @autoreleasepool
    {
        NSMutableDictionary     *licenseFeatures = [[NSMutableDictionary alloc]init];
        NSMutableDictionary     *licenseFile = [[NSMutableDictionary alloc]init];
        NSString *licenseFileName = @"license.bin";
        NSString *licenseInstallFileName = @"/etc/messagemover/license.bin";
        licenseFeatures[@"core"] = @{@"enable": @"YES"};
        licenseFeatures[@"sctp"] = @{@"enable": @"YES"};
        licenseFeatures[@"m2pa"] = @{@"enable": @"YES"};
        licenseFeatures[@"mtp3"] = @{@"enable": @"YES"};
        licenseFeatures[@"sccp"] = @{@"enable": @"YES"};
        licenseFeatures[@"tcap"] = @{@"enable": @"YES"};
        licenseFeatures[@"gsmmap"] = @{@"enable": @"YES"};

        NSString *serialNumber  = NULL;
        NSString *expiration    = NULL;
        NSString *licenseName  = NULL;
        NSString *licenseNumber     = NULL;
        BOOL	doInstall = NO;
        for(int i=1;i<argc;i++)
        {
            if(strcmp(argv[i],"--install")==0)
            {
                doInstall = YES;
                NSLog(@"doinstall=yes");
            }
            if(strcmp(argv[i],"--file")==0)
            {
                i++;
                licenseFileName = @(argv[i]);
            }
            else if(strcmp(argv[i],"--serial")==0)
            {
                i++;
                serialNumber = @(argv[i]);
                
            }        
            else if(strcmp(argv[i],"--demo")==0)
            {
                i++;
                int days;
                sscanf(argv[i],"%d",&days);

                time_t current;
                time(&current);
                current = current + (24*60*60*days);
                    
                    
                struct tm trec;
                struct	timeval  tp;
                struct	timezone tzp;
                gettimeofday(&tp, &tzp);
                gmtime_r(&current, &trec);
                expiration = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d.%06d",
                              trec.tm_year+1900,
                              trec.tm_mon+1,
                              trec.tm_mday,
                              trec.tm_hour,
                              trec.tm_min,
                              trec.tm_sec,
                              (int)tp.tv_usec];
            }
            else if(strcmp(argv[i],"--expiration")==0)
            {
                i++;
                expiration = @(argv[i]);
            }
            else if(strcmp(argv[i],"--license-name")==0)
            {
                i++;
                licenseName = @(argv[i]);
            }
            else if(strcmp(argv[i],"--license-number")==0)
            {
                i++;
                licenseNumber = @(argv[i]);
            }
            else if(strcmp(argv[i],"--smsc")==0)
            {
                licenseFeatures[@"smsc"] = @{@"enable": @"YES"};
            }
            else if((strcmp(argv[i],"--emiucp")==0) || (strcmp(argv[i],"--emi-ucp")==0))
            {
                licenseFeatures[@"emiucp"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--smpp")==0)
            {
                licenseFeatures[@"smpp"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--http")==0)
            {
                licenseFeatures[@"http"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--m3ua")==0)
            {
                licenseFeatures[@"m3ua"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--proxy")==0)
            {
                licenseFeatures[@"proxy"] = @{@"enable": @"YES"};
                licenseFeatures[@"smsproxy"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--http-hlr")==0)
            {
                licenseFeatures[@"http-hlr"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--mofwd")==0)
            {
                licenseFeatures[@"mofwd"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--quota")==0)
            {
                licenseFeatures[@"quota"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--interworking")==0)
            {
                licenseFeatures[@"interworking"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--rerouter")==0)
            {
                licenseFeatures[@"rerouter"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--billing")==0)
            {
                licenseFeatures[@"billing"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--logging")==0)
            {
                licenseFeatures[@"logging"] = @{@"enable": @"YES"};
            }
            else if(strcmp(argv[i],"--udp")==0)
            {
                licenseFeatures[@"udp"] = @{@"enable": @"YES"};
            }
        }

        if(licenseName)
        {
            licenseFile[@"license-name"] = licenseName;
        }
        if(licenseNumber)
        {
            licenseFile[@"license-number"] = licenseNumber;
        }
        if(expiration)
        {
            licenseFile[@"expiration"] = expiration;
        }

        licenseFile[@"features"] = licenseFeatures;
        if(serialNumber==NULL)
        {
            
            licenseFile[@"serial"] = GetMachineSerialNumber();
            licenseFile[@"interfaces"] = GetMACAddresses();
        }
        else
        {
            licenseFile[@"serial"] = serialNumber;
        }
        
        unlink("license.plist");
        unlink("license.bin");
        
        [licenseFile writeToFile:@"license.plist" atomically:NO];

        NSData *licenseData = [NSData dataWithContentsOfFile:@"license.plist"];
        NSData *key = [NSData dataWithBytes:key128 length:sizeof(key128)];
        NSData *chipertext = encryptData(licenseData,key);
        if(doInstall)
        {
            NSLog(@"Installing license to %@",licenseInstallFileName);
            [chipertext writeToFile:licenseInstallFileName atomically:YES];
        }
        
        NSLog(@"writing license to %@",licenseFileName);
        [chipertext writeToFile:licenseFileName atomically:YES];

        NSData *verifyData =[NSData dataWithContentsOfFile:licenseFileName];
        NSData *decryptedData = decryptData(verifyData,key);
        
        /* we dont want any trailing 0x00 bytes as this confuses GNUStep */
        size_t len = strnlen((void *)decryptedData.bytes, (size_t)decryptedData.length);
        decryptedData = [decryptedData subdataWithRange:NSMakeRange(0,len) ];
        
        NSString *tmpfile = [NSString stringWithFormat:@"/tmp/.mm.%d.plist",getpid()];

        [decryptedData writeToFile:tmpfile atomically:YES];
        NSDictionary *licDict = [NSDictionary dictionaryWithContentsOfFile:tmpfile];
        if(licDict == NULL)
        {
            NSLog(@"Produced result can not be read!\n");
        }else
        {
        	NSLog(@"Successfully read\n");
        }
    }
    return 0;
}

