//
//  mmlic.m
//  mmlic
//
//  Created by Andreas Fink on 15.11.11.
//  Copyright (c) 2011 Andreas Fink. All rights reserved.
//

#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <locale.h>

#import <Foundation/Foundation.h>
#ifndef	LINUX
#import <CoreFoundation/CoreFoundation.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "../version.h"
#import <ulib/ulib.h>
#import <uliblicense/uliblicense.h>

int main (int argc, const char * argv[])
{
    printf("mmlic version " VERSION "\n");
    
    struct stat statbuf;
    if(stat("/etc/messagemover",&statbuf)!=0)
        mkdir("/etc/messagemover",0644);
    
    @autoreleasepool
    {
        NSMutableDictionary     *licenseFeatures = [[NSMutableDictionary alloc]init];
        NSMutableDictionary     *licenseFile = [[NSMutableDictionary alloc]init];
        
        UMSignedLicense *slicense = [[UMSignedLicense alloc]init];
        UMLicense *mmlicense =  [[UMLicense alloc]init];
        mmlicense.licenseType = @"permanent";
        slicense.license = mmlicense;

        UMLicenseProduct *smsc          = [[UMLicenseProduct alloc]initWithName:@"smsc"];
        UMLicenseProduct *smsproxy      = [[UMLicenseProduct alloc]initWithName:@"smsproxy"];
        UMLicenseProduct *rerouter      = [[UMLicenseProduct alloc]initWithName:@"rerouter"];
        UMLicenseProduct *estp          = [[UMLicenseProduct alloc]initWithName:@"estp"];
        UMLicenseProduct *ss7firewall   = [[UMLicenseProduct alloc]initWithName:@"ss7firewall"];
        UMLicenseProduct *cnamserver    = [[UMLicenseProduct alloc]initWithName:@"cnamserver"];

#define  ADD_PRODUCT_ALL(name) \
        [smsc addFeatureWithName:name]; \
        [smsproxy addFeatureWithName:name]; \
        [rerouter addFeatureWithName:name]; \
        [estp addFeatureWithName:name]; \
        [ss7firewall addFeatureWithName:name]; \
        [cnamserver addFeatureWithName:name]

        ADD_PRODUCT_ALL(@"core");
        ADD_PRODUCT_ALL(@"sctp");
        ADD_PRODUCT_ALL(@"m2pa");
        ADD_PRODUCT_ALL(@"mtp3");
        ADD_PRODUCT_ALL(@"sccp");
        ADD_PRODUCT_ALL(@"tcap");
        ADD_PRODUCT_ALL(@"gsmmap");
        
        [smsc addFeatureWithName:@"smsc"];
        [smsproxy addFeatureWithName:@"smsproxy"];
        [rerouter addFeatureWithName:@"rerouter"];
        [estp addFeatureWithName:@"estp"];
        [ss7firewall addFeatureWithName:@"ss7firewall"];
        [cnamserver addFeatureWithName:@"cnamserver"];

        ADD_PRODUCT_ALL(@"smsc");
        

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
        NSDate *expirationDate = NULL;
        NSString *licenseName  = NULL;
        NSString *licenseNumber     = NULL;
        BOOL doInstall = NO;
        BOOL doLegacy = NO;
        NSString *key = NULL;
        for(int i=1;i<argc;i++)
        {
            if(strcmp(argv[i],"--install")==0)
            {
                doInstall = YES;
                NSLog(@"doinstall=yes");
            }
            if(strcmp(argv[i],"--legacy")==0)
            {
                doLegacy = YES;
                NSLog(@"legacy=yes");
            }
            if(strcmp(argv[i],"--key")==0)
            {
                i++;
                if(i<argc)
                {
                    NSString *keyFileName = @(argv[i]);
                    NSData *data = [NSData dataWithContentsOfFile:keyFileName];
                    key = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                }
            }

            if(strcmp(argv[i],"--file")==0)
            {
                i++;
                if(i<argc)
                {
                    licenseFileName = @(argv[i]);
                }
            }
            else if(strcmp(argv[i],"--serial")==0)
            {
                i++;
                if(i<argc)
                {
                    serialNumber = @(argv[i]);
                }
                
            }        
            else if(strcmp(argv[i],"--demo")==0)
            {
                i++;
                int days;
                if(i<argc)
                {
                    sscanf(argv[i],"%d",&days);
                    
                    time_t current;
                    time(&current);
                    current = current + (24*60*60*days);
                    
                    struct tm trec;
                    struct    timeval  tp;
                    struct    timezone tzp;
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
                    expirationDate = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)(24*60*60*days)];
                    mmlicense.licenseType = @"temporary";
                }
            }
            else if(strcmp(argv[i],"--renew-url")==0)
            {
                i++;
                if(i<argc)
                {
                    mmlicense.licenseType = @"renewing";
                    mmlicense.licenseRenewUrl = @(argv[i]);
                }
            }

            else if(strcmp(argv[i],"--expiration")==0)
            {
                i++;
                if(i<argc)
                {
                    expiration = @(argv[i]);
                    expirationDate = [NSDate dateWithString:@(argv[i])];
                    mmlicense.licenseType = @"temporary";
                }
            }
            else if(strcmp(argv[i],"--license-name")==0)
            {
                i++;
                if(i<argc)
                {
                    licenseName = @(argv[i]);
                }
            }
            else if(strcmp(argv[i],"--license-number")==0)
            {
                i++;
                if(i<argc)
                {
                    licenseNumber = @(argv[i]);
                }
            }
            else if(strcmp(argv[i],"--smsc")==0)
            {
                licenseFeatures[@"smsc"] = @{@"enable": @"YES"};
                [mmlicense addProduct:smsc];
            }
            else if((strcmp(argv[i],"--emiucp")==0) || (strcmp(argv[i],"--emi-ucp")==0))
            {
                licenseFeatures[@"emiucp"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"emiucp");
            }
            else if(strcmp(argv[i],"--smpp")==0)
            {
                licenseFeatures[@"smpp"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"smpp");
            }
            else if(strcmp(argv[i],"--http")==0)
            {
                licenseFeatures[@"http"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"http");
            }
            else if(strcmp(argv[i],"--m3ua")==0)
            {
                licenseFeatures[@"m3ua"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"m3ua");
            }
            else if((strcmp(argv[i],"--proxy")==0) || (strcmp(argv[i],"--smsproxy")==0))
            {
                [mmlicense addProduct:smsproxy];
            }
            else if(strcmp(argv[i],"--http-hlr")==0)
            {
                licenseFeatures[@"http-hlr"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"http-hlr");
            }
            else if(strcmp(argv[i],"--mofwd")==0)
            {
                licenseFeatures[@"mofwd"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"mofwd");
            }
            else if(strcmp(argv[i],"--quota")==0)
            {
                licenseFeatures[@"quota"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"quota");
            }
            else if(strcmp(argv[i],"--interworking")==0)
            {
                licenseFeatures[@"interworking"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"interworking");
            }
            else if(strcmp(argv[i],"--rerouter")==0)
            {
                licenseFeatures[@"rerouter"] = @{@"enable": @"YES"};
                [mmlicense addProduct:rerouter];
            }
            else if(strcmp(argv[i],"--billing")==0)
            {
                licenseFeatures[@"billing"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"billing");
            }
            else if(strcmp(argv[i],"--logging")==0)
            {
                licenseFeatures[@"logging"] = @{@"enable": @"YES"};
                ADD_PRODUCT_ALL(@"logging");
            }
            else if(strcmp(argv[i],"--udp")==0)
            {
                ADD_PRODUCT_ALL(@"udp");
            }
            else if(strcmp(argv[i],"--estp")==0)
            {
                licenseFeatures[@"estp"] = @{@"enable": @"YES"};
                [mmlicense addProduct:estp];
            }
            else if(strcmp(argv[i],"--ss7firewall")==0)
            {
                licenseFeatures[@"ss7firewall"] = @{@"enable": @"YES"};
                [mmlicense addProduct:ss7firewall];
            }
            else if(strcmp(argv[i],"--cnamserver")==0)
            {
                licenseFeatures[@"cnamserver"] = @{@"enable": @"YES"};
                [mmlicense addProduct:cnamserver];
            }
        }

        if(licenseName)
        {
            licenseFile[@"license-name"] = licenseName;
            mmlicense.licenseOwner = licenseName;
        }
        if(licenseNumber)
        {
            licenseFile[@"license-number"] = licenseNumber;
            mmlicense.licenseSerialNumber = licenseNumber;
        }
        if(expiration)
        {
            licenseFile[@"expiry"] = expiration;
        }
        if(expirationDate)
        {
            mmlicense.licenseExpiration = expirationDate;
        }

        licenseFile[@"features"] = licenseFeatures;
        if(serialNumber==NULL)
        {
            NSArray *ips = [UMUtil getNonLocalIPs];
            NSArray *macs = [UMUtil getArrayOfMacAddresses];
            NSString *serial = [UMUtil getMachineSerialNumber];
            NSString *uuid = [UMUtil getMachineUUID];
            NSString *os = NULL;
            licenseFile[@"serial"] = serial;
            licenseFile[@"interfaces"] = macs;
            licenseFile[@"ipaddresses"] = ips;
            
            for (NSString *ip in ips)
            {
                UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                rest.lockedToIp = ip;
                [mmlicense addRestriction: rest];
            }
            for (NSString *mac in macs)
            {
                UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                rest.lockedToMacAddress = mac;
                [mmlicense addRestriction: rest];
            }
            if(serial)
            {
                UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                rest.lockedToSerial = serial;
                [mmlicense addRestriction: rest];
            }
            if(uuid)
            {
                UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                rest.lockedToUUID = uuid;
                [mmlicense addRestriction: rest];
            }
            if(os)
            {
                UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                rest.lockedToOperatingSystem = os;
                [mmlicense addRestriction: rest];
            }
        }
        else
        {
            licenseFile[@"serial"] = serialNumber;

            UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
            rest.lockedToSerial = serialNumber;
            [mmlicense addRestriction: rest];
        }
        
        if(doLegacy)
        {
            unlink("license.plist");
            unlink("license.bin");
            [licenseFile writeToFile:@"license.plist" atomically:NO];

            NSData *licenseData = [NSData dataWithContentsOfFile:@"license.plist"];
            UMLegacyLicense *llic = [[UMLegacyLicense alloc]init];
            llic.plaintext = licenseData;
            [llic encrypt];
            NSData *chiphertext = llic.ciphertext;
            if(doInstall)
            {
                NSLog(@"Installing license to %@",licenseInstallFileName);
                [chiphertext writeToFile:licenseInstallFileName atomically:YES];
            }
            NSLog(@"writing license to %@",licenseFileName);
            [chiphertext writeToFile:licenseFileName atomically:YES];

            NSData *verifyData = [NSData dataWithContentsOfFile:licenseFileName];
            llic.ciphertext = verifyData;
            [llic decrypt];
            NSData *decryptedData = llic.plaintext;
        
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
        if(slicense)
        {
            [slicense signLicenseWithRSAPublicKey:key];

            NSString *licenseFileName = [NSString stringWithFormat:@"%@.license",slicense.license.licenseSerialNumber];
            if(key)
            {
                [slicense encryptLicenseWithRSAPublicKey:key];
            }
            NSData *data = [slicense berEncoded];
            NSLog(@"writing new license to %@",licenseFileName);
            [data writeToFile:licenseFileName atomically:YES];
        }
    }
    return 0;
}

