
//
//  common.m
//  mmlic/mminfo
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "common.h"
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/wait.h>

#define RXPIPE	0
#define TXPIPE	1

const unsigned char key128[128] = {0x11,0xe7,0x5c,0xf8,0x55,0xc2,0xf1,0xb1,0xe5,0xe5,0x51,0x4c,0x94,0x5e,0xb8,0x77,0x36,0xe6,0x81,0xf8,0x1d,0x2f,0x04,0x88,0xd6,0x21,0x92,0x4b,0x58,0x54,0x04,0x69,0x3b,0x61,0x62,0x90,0x23,0x53,0x42,0x09,0x38,0x93,0x55,0xcc,0xf2,0x0d,0x43,0x28,0xf4,0xc4,0x20,0x11,0xf3,0x25,0x9a,0xca,0x46,0x2c,0x15,0x9e,0x81,0x1a,0x08,0xbc,0x7b,0x6a,0x4d,0x9e,0xbd,0x8f,0xa7,0xf5,0x22,0xfd,0xc1,0x14,0x0a,0x05,0x3c,0xfe,0xc9,0x5d,0x10,0xbd,0x82,0xaa,0x87,0xc8,0xd6,0x9c,0x66,0x57,0xb6,0x6e,0x14,0x31,0xd8,0x61,0xd0,0x95,0xf0,0x77,0x8a,0x12,0x74,0x4c,0x27,0x7f,0x51,0x63,0x7d,0x1a,0xc0,0x8d,0xd7,0x42,0x37,0x5e,0x0a,0x0e,0xfb,0x71,0x65,0xb1,0xdf,0x79,0xe3,0xb8};


NSString *hexNSString(const char *in);


#ifdef LINUX

NSData *encryptData(NSData *data, NSData *keyData)
{
    
    size_t output_size = (([data length]*4+1023) / 1024) * 1024;
    unsigned char *output_ptr =  (unsigned char *)malloc(output_size);
    
    size_t input_size = (([data length]+1023) / 1024) * 1024;
    unsigned char *input_ptr =  (unsigned char *)malloc(input_size);
    
    size_t key_size = [keyData length];
    const unsigned char *key =  (const unsigned char *)[keyData bytes];
    
    memset(input_ptr,0x00,input_size);
    memcpy(input_ptr,[data bytes],[data length]);
    
    /* we pad to the next 1k with zero's */
    size_t new_output_size = 0;
    
    int j = 0;
    for(int i=0;i<input_size;i++)
    {
        output_ptr[i] = input_ptr[i] ^ key[j];
        j = j+1;
        j = j % key_size;
        new_output_size++;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    return result;
}

NSData *decryptData(NSData *data, NSData *keyData)
{
    return encryptData(data,keyData);
}

#else /* non linux */

NSData *encryptData(NSData *data, NSData *key)
{
    CCCryptorStatus ccStatus;
    CCOptions options = 0; //kCCOptionPKCS7Padding;

    
    size_t output_size = (([data length]*4+1023) / 1024) * 1024;
    void *output_ptr =  malloc(output_size);

    size_t input_size = (([data length]+1023) / 1024) * 1024;
    void *input_ptr =  malloc(input_size);
    memset(input_ptr,0x00,input_size);
    memcpy(input_ptr,[data bytes],[data length]);
    
    /* we pad to the next 1k with zero's */
    size_t new_output_size = 0;
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmRC4,
                       options,
                       [key bytes],
                       [key length],
                       NULL,
                       input_ptr,
                       input_size,
                       output_ptr,          /* data RETURNED here */
                       output_size ,
                       &new_output_size);
    if(ccStatus !=0)
    {
        NSLog(@"Encrypt fails with Error: %d %s",ccStatus,cryptErrorString(ccStatus));
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];

    if(output_ptr)
    {
        free(output_ptr);
    }
    output_ptr=NULL;
    if(input_ptr)
    {
        free(input_ptr);
    }
    input_ptr=NULL;
    return result;
}

NSData *decryptData(NSData *data,NSData *key)
{
    CCCryptorStatus ccStatus;
    CCOptions options = 0; //kCCOptionPKCS7Padding;
    
    size_t output_size = (([data length]+1023) / 1024) * 1024;
    void *output_ptr =  malloc(output_size);
    size_t new_output_size = 0;
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmRC4,
                       options,
                       [key bytes],
                       [key length],
                       NULL,
                       [data bytes],
                       [data length],
                       output_ptr,          /* data RETURNED here */
                       output_size ,
                       &new_output_size);
    
    if(ccStatus !=0)
        ccStatus = CCCrypt(kCCDecrypt,
                           kCCAlgorithmDES,
                           options,
                           [key bytes],
                           [key length],
                           NULL,
                           [data bytes],
                           [data length],
                           output_ptr,          /* data RETURNED here */
                           output_size ,
                           &new_output_size);
    if(ccStatus !=0)
        ccStatus = CCCrypt(kCCDecrypt,
                           kCCAlgorithm3DES,
                           options,
                           [key bytes],
                           [key length],
                           NULL,
                           [data bytes],
                           [data length],
                           output_ptr,          /* data RETURNED here */
                           output_size ,
                           &new_output_size);
    if(ccStatus !=0)
        ccStatus = CCCrypt(kCCDecrypt,
                           kCCAlgorithmCAST,
                           options,
                           [key bytes],
                           [key length],
                           NULL,
                           [data bytes],
                           [data length],
                           output_ptr,          /* data RETURNED here */
                           output_size ,
                           &new_output_size);
    
    if(ccStatus !=0)
        ccStatus = CCCrypt(kCCDecrypt,
                           kCCAlgorithmAES128,
                           options,
                           [key bytes],
                           [key length],
                           NULL,
                           [data bytes],
                           [data length],
                           output_ptr,          /* data RETURNED here */
                           output_size ,
                           &new_output_size);
    
    if(ccStatus !=0)
    {
        if(output_ptr)
        {
            free(output_ptr);
        }
        output_ptr = NULL;
        return NULL;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    if(output_ptr)
    {
        free(output_ptr);
    }
    output_ptr=NULL;
    return result;
}

const char *cryptErrorString(int code)
{
    switch(code)
    {
        case kCCSuccess:
            return "kCCSuccess";
        case kCCParamError:
            return "kCCParamError";
        case kCCBufferTooSmall:
            return "kCCBufferTooSmall";
        case kCCMemoryFailure:
            return "kCCMemoryFailure";
        case kCCAlignmentError:
            return "kCCAlignmentError";
        case kCCDecodeError:
            return "kCCDecodeError";
        case kCCUnimplemented:
            return "kCCUnimplemented";
    }
    return "";
}

#endif





NSString *hexNSString(const char *in)
{
	NSMutableString *result;
	int i;
	size_t n;
	result = [[NSMutableString alloc]init];
	n = strlen(in);
	for(i=0;i<n;i++)
	{
		[result appendFormat:@"%02X",((unsigned char *)in)[i]];
	}
	return result;
}

