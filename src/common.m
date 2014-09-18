
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

NSArray *readChildProcess(NSArray *args);
NSString *GetMacAddr(NSString *interfaceName);
NSString *GetMachineUUID(void);

const unsigned char key128[128] = {0x11,0xe7,0x5c,0xf8,0x55,0xc2,0xf1,0xb1,0xe5,0xe5,0x51,0x4c,0x94,0x5e,0xb8,0x77,0x36,0xe6,0x81,0xf8,0x1d,0x2f,0x04,0x88,0xd6,0x21,0x92,0x4b,0x58,0x54,0x04,0x69,0x3b,0x61,0x62,0x90,0x23,0x53,0x42,0x09,0x38,0x93,0x55,0xcc,0xf2,0x0d,0x43,0x28,0xf4,0xc4,0x20,0x11,0xf3,0x25,0x9a,0xca,0x46,0x2c,0x15,0x9e,0x81,0x1a,0x08,0xbc,0x7b,0x6a,0x4d,0x9e,0xbd,0x8f,0xa7,0xf5,0x22,0xfd,0xc1,0x14,0x0a,0x05,0x3c,0xfe,0xc9,0x5d,0x10,0xbd,0x82,0xaa,0x87,0xc8,0xd6,0x9c,0x66,0x57,0xb6,0x6e,0x14,0x31,0xd8,0x61,0xd0,0x95,0xf0,0x77,0x8a,0x12,0x74,0x4c,0x27,0x7f,0x51,0x63,0x7d,0x1a,0xc0,0x8d,0xd7,0x42,0x37,0x5e,0x0a,0x0e,0xfb,0x71,0x65,0xb1,0xdf,0x79,0xe3,0xb8};

#ifdef LINUX
NSArray *GetCpuSerialNumbers(void);
NSArray *GetUUIDs(void);
#endif

NSString *hexNSString(const char *in);

#ifdef LINUX

NSDictionary *GetMACAddresses(void)
{
	NSMutableDictionary *interfaces = [[NSMutableDictionary alloc]init];

	NSArray *ifnames = [NSArray arrayWithObjects:@"eth0",@"eth1",@"eth2",@"eth3",@"en0",@"en1",@"en2",@"en3",nil];
	
	for (NSString *ifname in ifnames)
	{
		NSString *hwaddr = GetMacAddr(ifname);
		if(hwaddr)
		{            
			[interfaces setObject:hwaddr forKey:ifname];
		}
	}
	return interfaces;
}


#else

NSDictionary *GetMACAddresses(void)
{
    NSMutableDictionary            *result = [[NSMutableDictionary alloc]init];
    
    CFMutableDictionaryRef	matchingDict;
	io_iterator_t			intfIterator;
    io_object_t				intfService;
    io_object_t				controllerService;
    kern_return_t			kernResult = KERN_FAILURE;
	UInt8					ethernet_address[kIOEthernetAddressSize];
    int						i=0;
	CFTypeRef				MACAddressAsCFData;        
	
	i = 0;
	matchingDict	= IOServiceMatching(kIOEthernetInterfaceClass);
    kernResult		= IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &intfIterator);
    if (KERN_SUCCESS == kernResult)
    {
        while ((intfService = IOIteratorNext(intfIterator)))
        {
            bzero(ethernet_address, kIOEthernetAddressSize);
            kernResult = IORegistryEntryGetParentEntry(intfService,kIOServicePlane, &controllerService);
            if (KERN_SUCCESS == kernResult)
            {
                // Retrieve the MAC address property from the I/O Registry in the form of a CFData
                MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
                                                                     CFSTR(kIOMACAddress),
                                                                     kCFAllocatorDefault,
                                                                     0);
                if (MACAddressAsCFData)
                {
                    CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), ethernet_address);
                    
                    NSString *address = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                    ethernet_address[0], ethernet_address[1], ethernet_address[2], ethernet_address[3], ethernet_address[4], ethernet_address[5]];
                    NSString *ifname = [NSString stringWithFormat:@"if%d",i++];
                    result[ifname] = address;
                    CFRelease(MACAddressAsCFData);
                }
                (void) IOObjectRelease(controllerService);
            }
            (void) IOObjectRelease(intfService);
        }
    }
    return result;
}
#endif


#ifdef	LINUX

#define MAXLINE 256

NSString *GetMachineSerialNumber(void)
{
    NSMutableString *serialNumber = NULL;
    int found = 0;
    
    NSArray *cmd = [NSArray arrayWithObjects:@"/usr/sbin/dmidecode",@"-t",@"system",NULL];
    NSArray *lines = readChildProcess(cmd);
    
    for (NSString *line in lines)
    {
        const char *s = strstr([line UTF8String],"Serial Number: ");
        if(s)
        {
            s += strlen("Serial Number: ");
            
            size_t len = strlen(s);
            int i;
            serialNumber = [[NSMutableString alloc] init];
            for(i=0;i<len;i++)
            {
                switch(s[i])
                {
                    case '\0':
                    case '\n':
                    case '\r':
                    case '\t':
                    case ' ':
                        break;
                    default:
                        [serialNumber appendFormat:@"%c",s[i]];
                        break;
                }
            }
            found=1;
        }
    }
    if([serialNumber isEqualTo:@"NotSpecified"])
    {
        NSArray *cpuSerials = GetCpuSerialNumbers();
        if([cpuSerials count]>0)
        {
            serialNumber = [cpuSerials objectAtIndex:0];
        }
        else
        {
            return NULL;
        }
    }
    return serialNumber;
}

NSString *GetMachineUUID(void)
{
    NSString *uuidNumber = NULL;
    int found = 0;
    
    NSArray *cmd = [NSArray arrayWithObjects:@"/usr/sbin/dmidecode",@"-t",@"system",NULL];
    NSArray *lines = readChildProcess(cmd);
    
    for (NSString *line in lines)
    {
        const char *s = strstr([line UTF8String],"UUID: ");
        if(s)
        {
            s += strlen("UUID: ");
            
            size_t len = strlen(s);
            int i;
            uuidNumber = [[ NSString stringWithUTF8String: s]
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            found=1;
        }
    }
    return uuidNumber;
}

#else /* non LINUX */

NSString *GetMachineSerialNumber(void)
{
    NSString* result = nil;
    
#if TARGETOSIPHONE
    result = [[UIDevice currentDevice] uniqueIdentifier];
#else
    CFStringRef serialNumber = NULL;
    
    io_service_t platformExpert = IOServiceGetMatchingService(
                                                            kIOMasterPortDefault,
                                                            IOServiceMatching("IOPlatformExpertDevice")
                                                            );
    
    if (platformExpert)
    {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(
                                                                           platformExpert,
                                                                           CFSTR(kIOPlatformSerialNumberKey),
                                                                           kCFAllocatorDefault,
                                                                           0
                                                                           );
        serialNumber = (CFStringRef)serialNumberAsCFString;
        IOObjectRelease(platformExpert);
    }
    if (serialNumber)
    {
        result = @ ([(NSString *)CFBridgingRelease(serialNumber) UTF8String]);
    }
    else
    {
        result = @"unknown";
    }
#endif //TARGETOSIPHONE
     return result;
}


NSString *GetMachineUUID(void)
{
    return GetMachineSerialNumber();
}

#endif

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
    free(output_ptr);
    free(input_ptr);
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
        free(output_ptr);
        return NULL;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    free(output_ptr);
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


NSString *GetMacAddr(NSString *interfaceName)
{
    
    char buffer[256];
    char line[256];
    char *input_line = NULL;
    char tmpfilename[256] = "/tmp/.mminfo-tmp-XXXXXX";
    NSString *ethernetAddress = NULL;
    
    int fdes = mkstemp(tmpfilename);

    sprintf(buffer,"/sbin/ifconfig %s > %s 2>/dev/null",[interfaceName UTF8String],tmpfilename);
    system(buffer);
    FILE *f = fdopen(fdes,"r");
    
    while((input_line = fgets(line,sizeof(line),f)))
    {
        const char *s = strstr(input_line,"HWaddr");
        if(s)
        {
            s += strlen("HWaddr");
            ethernetAddress = @(s);
            break;
        }
        
        s = strstr(input_line,"ether ");
        if(s)
        {
            s += strlen("ether ");
            ethernetAddress = @(s);
            break;
        }
    }

    if(ethernetAddress!=NULL)
    {
        ethernetAddress = [ethernetAddress stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    fclose(f);
    unlink(tmpfilename);
    return ethernetAddress;
}

#ifdef LINUX
NSArray *GetCpuSerialNumbers(void)
{
    NSArray *cmd = [NSArray arrayWithObjects:@"/usr/sbin/dmidecode",@"-t",@"processor",NULL];
    NSArray *lines = readChildProcess(cmd);
    NSMutableArray  *serialNumbers = [[NSMutableArray alloc]init];
    int found = 0;
    
    for(NSString *line in lines)
    {
        const char *s = strstr([line UTF8String],"ID: ");
        if(s)
        {
            s += strlen("ID: ");
            size_t len = strlen(s);
            int i;
            NSMutableString *serialNumber = [[NSMutableString alloc] init];
            for(i=0;i<len;i++)
            {
                switch(s[i])
                {
                    case '\0':
                    case '\n':
                    case '\r':
                    case '\t':
                    case ' ':
                        break;
                    default:
                        [serialNumber appendFormat:@"%c",s[i]];
                        break;
                }
            }
            if([serialNumbers indexOfObjectIdenticalTo:serialNumber]==NSNotFound)
            {
                [serialNumbers addObject:serialNumber];
            }
            serialNumber = NULL;
            found++;
        }
    }
    if(found==0)
    {
        serialNumbers=NULL;
        return NULL;
    }
    return serialNumbers;
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

NSArray *readChildProcess(NSArray *args)
{
	int pipefds[2];
	pid_t pid;
    NSMutableArray *result = NULL;
	if(pipe(pipefds)< 0)
	{
		return NULL;
	}
	pid = fork();
	if(pid==-1)
	{
		return NULL;
	}
	if(pid==0)
	{
		/* child process */
		dup2(pipefds[TXPIPE], STDOUT_FILENO);
		close(pipefds[RXPIPE]);
		        
        char  **cmd;
        int n = (int)[args count];
        int i;
        cmd = calloc(sizeof (char *),n+1);
        for(i=0;i<n;i++)
        {
            cmd[i]=(char *)[args[i] UTF8String];
        }
        if (execvp(cmd[0], cmd) == -1)
		{
            free(cmd);
			exit(-1);
		}
        exit(0);
	}
	else
	{
		int returnStatus=0;
		waitpid(pid, &returnStatus, 0);
		close(pipefds[TXPIPE]);
        
		FILE *fromChild = fdopen(pipefds[RXPIPE], "r");

        result = [[NSMutableArray alloc]init];

        char line[257];
		size_t linecap=255;
        
        /*
		char *line=NULL;
		size_t linecap=255;
		ssize_t linelen;
		while ((linelen = getline(&line, &linecap, fromChild)) > 0)
         */
        while(fgets(line, (int)linecap, fromChild))
		{
            [result addObject:@(line)];
			if(feof(fromChild))
			{
				break;
			}
		}
        if(line)
        {
            free(line);
        }
    }
    return result;
}
