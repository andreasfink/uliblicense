//
//  mmdisp.m
//  mmlic
//
//  Created by Andreas Fink on 22.03.13.
//
//

#import "common.h"

#include <sys/stat.h>

int main(int argc, const char **argv)
{
    printf("mmdisp version 1.0\n");
    struct stat statbuf;
    
    if(stat("/etc/messagemover",&statbuf)!=0)
    {
        mkdir("/etc/messagemover",0644);
    }
    @autoreleasepool
    {
        NSData *key = [NSData dataWithBytes:key128 length:sizeof(key128)];
        NSString *licenseFileName = @"/etc/messagemover/license.bin";
        if(argc > 1)
        {
            licenseFileName=[NSString stringWithUTF8String:argv[1]];
        }
        NSLog(@"Reading %@",licenseFileName);
        NSData *verifyData =[NSData dataWithContentsOfFile:licenseFileName];
        NSData *decryptedData = decryptData(verifyData,key);
        /* we dont want any trailing 0x00 bytes as this confuses GNUStep */
        size_t len = strnlen((void *)decryptedData.bytes, (size_t)decryptedData.length);
        decryptedData = [decryptedData subdataWithRange:NSMakeRange(0,len) ];

        NSString *tmpfile = [NSString stringWithFormat:@"/tmp/.mm.%d.plist",getpid()];
        [decryptedData writeToFile:tmpfile atomically:YES];
        NSMutableDictionary *licDict = [NSMutableDictionary dictionaryWithContentsOfFile:tmpfile];
        if(licDict == NULL)
        {
            NSLog(@"Produced result can not be read!\n");
        }
        else
        {
            NSLog(@"Successfully read\n");
            NSLog(@"%@",licDict);
        }
    }
    return 0;
}
