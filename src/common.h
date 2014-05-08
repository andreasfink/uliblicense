//
//  common.h
//  mmlic/mminfo
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <time.h>
#include <sys/time.h>
#include <locale.h>

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#ifdef	LINUX

#else

#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IONetworkInterface.h>
#import <IOKit/network/IOEthernetController.h>
#import <CommonCrypto/CommonCryptor.h>

#endif

#include <unistd.h>

#define     CRYPTO_ALGO kCCAlgorithmCAST //kCCAlgorithm3DES    //kCCAlgorithmAES128

extern const unsigned char key128[128];

NSDictionary *GetMACAddresses(void);
NSString *GetMachineSerialNumber(void);
const char *cryptErrorString(int code);

NSData *encryptData(NSData *data, NSData *key);
NSData *decryptData(NSData *data, NSData *key);
