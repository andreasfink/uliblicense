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
#import <CoreFoundation/CoreFoundation.h>

#include "common.h"


#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int main (int argc, const char * argv[])
{
    printf("mmlic version 1.1\n");
    
    struct stat statbuf;
    if(stat("/etc/messagemover",&statbuf)!=0)
        mkdir("/etc/messagemover",0644);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSMutableDictionary     *licenseFeatures = [[[NSMutableDictionary alloc]init]autorelease];
    NSMutableDictionary     *licenseFile = [[[NSMutableDictionary alloc]init]autorelease];
    NSString *licenseFileName = @"license.bin";
    NSString *licenseInstallFileName = @"/etc/messagemover/license.bin";
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"core"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"sctp"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"m2pa"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"mtp3"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"sccp"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"tcap"];
    [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"gsmmap"];

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
            licenseFileName = [NSString stringWithUTF8String:argv[i]];
        }
        else if(strcmp(argv[i],"--serial")==0)
        {
            i++;
            serialNumber = [NSString stringWithUTF8String:argv[i]];
            
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
            expiration = [NSString stringWithUTF8String:argv[i]];
        }
        else if(strcmp(argv[i],"--license-name")==0)
        {
            i++;
            licenseName = [NSString stringWithUTF8String:argv[i]];
        }
        else if(strcmp(argv[i],"--license-number")==0)
        {
            i++;
            licenseNumber = [NSString stringWithUTF8String:argv[i]];
        }
        else if(strcmp(argv[i],"--smsc")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"smsc"];
        }
        else if((strcmp(argv[i],"--emiucp")==0) || (strcmp(argv[i],"--emi-ucp")==0))
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"emiucp"];
        }
        else if(strcmp(argv[i],"--smpp")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"smpp"];
        }
        else if(strcmp(argv[i],"--http")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"http"];
        }
        else if(strcmp(argv[i],"--m3ua")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"m3ua"];
        }
        else if(strcmp(argv[i],"--proxy")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"proxy"];
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"smsproxy"];
        }
        else if(strcmp(argv[i],"--http-hlr")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"http-hlr"];
        }
        else if(strcmp(argv[i],"--mofwd")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"mofwd"];
        }
        else if(strcmp(argv[i],"--quota")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"quota"];
        }
        else if(strcmp(argv[i],"--interworking")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"interworking"];
        }
        else if(strcmp(argv[i],"--rerouter")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"rerouter"];
        }
        else if(strcmp(argv[i],"--billing")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"billing"];
        }
        else if(strcmp(argv[i],"--logging")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"logging"];
        }
        else if(strcmp(argv[i],"--udp")==0)
        {
            [licenseFeatures setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"enable",NULL] forKey:@"udp"];
        }
    }

    if(licenseName)
    {
        [licenseFile setObject:licenseName forKey:@"license-name"];
    }
    if(licenseNumber)
    {
        [licenseFile setObject:licenseNumber forKey:@"license-number"];
    }
    if(expiration)
    {
        [licenseFile setObject:expiration forKey:@"expiration"];
    }

    [licenseFile setObject:licenseFeatures forKey:@"features"];
    if(serialNumber==NULL)
    {
        
        [licenseFile setObject:GetMachineSerialNumber() forKey:@"serial"];
        [licenseFile setObject:GetMACAddresses() forKey:@"interfaces"];
    }
    else
    {
        [licenseFile setObject:serialNumber forKey:@"serial"];
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
    NSString *tmpfile = [NSString stringWithFormat:@"/tmp/.mm.%d.plist",getpid()];
    
    [decryptedData writeToFile:tmpfile atomically:YES];
    NSMutableDictionary *licDict = [NSMutableDictionary dictionaryWithContentsOfFile:tmpfile];
    if(licDict == NULL)
        NSLog(@"Produced result can not be read!\n");
    else
        NSLog(@"Successfully read\n");
    [pool drain];
    return 0;
}

