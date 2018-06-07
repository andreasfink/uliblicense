//
//  main.m
//  mmconvert
//
//  Created by Andreas Fink on 06.06.18.
//

#import <Foundation/Foundation.h>
#include "../version.h"
#import <uliblicense/uliblicense.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSDictionary *appDefinition = @
        {
            @"version" : @(VERSION),
            @"executable" : @"mmdisplay",
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
                                               @"name"  : @"input",
                                               @"short" : @"-i",
                                               @"long"  : @"--input-file",
                                               @"argument" : @"filename",
                                               @"help"  : @"input file to convert",
                                               },
                                           @{
                                               @"name"  : @"output",
                                               @"short" : @"-o",
                                               @"long"  : @"--output-file",
                                               @"argument" : @"filename",
                                               @"help"  : @"output file",
                                               },
                                           @{
                                               @"name"  : @"email",
                                               @"short" : @"-e",
                                               @"long"  : @"--email",
                                               @"argument" : @"email-address",
                                               @"help"  : @"email address of the owner of the license",
                                               },
                                           @{
                                               @"name"  : @"encryption-key",
                                               @"short" : @"-k",
                                               @"long"  : @"--encryption-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"use indicated encryption key file",
                                               },
                                           @{
                                               @"name"  : @"signature-key",
                                               @"short" : @"-s",
                                               @"long"  : @"--signature-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"use indicated signature key file",
                                            }];

        UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                                           appDefinition:appDefinition
                                                                                    argc:argc
                                                                                    argv:argv];
        [_commandLine handleStandardArguments];
        NSDictionary *params = _commandLine.params;
        
        UMLicenseDirectory *licdir = [[UMLicenseDirectory alloc]init];
        NSString *encryptionKey = NULL;
        NSString *signatureKey = NULL;
        NSString *outputLicenseFileName = NULL;
        
        if(params[@"encryption-key"])
        {
            NSArray *filenames = params[@"encryption-key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    encryptionKey = key;
                }
            }
        }
        if(params[@"signature-key"])
        {
            NSArray *filenames = params[@"signature-key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    signatureKey = key;
                }
            }
        }
        if(encryptionKey==NULL)
        {
            fprintf(stderr,"encryption key is mandatory\n");
            exit(-1);
        }

        if(signatureKey==NULL)
        {
            fprintf(stderr,"signature key is mandatory\n");
            exit(-1);
        }

        if(params[@"output"])
        {
            NSArray *filenames = params[@"output"];
            for(NSString *filename in filenames)
            {
                outputLicenseFileName = filename;
            }
        }


        if(params[@"input"])
        {
            NSArray *filenames = params[@"input"];
            for(NSString *filename in filenames)
            {
                UMLegacyLicense *ll  = [[UMLegacyLicense alloc]init];
                NSData *data = [NSData dataWithContentsOfFile:filename];
                if(data == NULL)
                {
                    fprintf(stderr,"Error: can not read license file %s\n",filename.UTF8String);
                    break;
                }
                ll.ciphertext = data;
                [ll decrypt];
                data = ll.plaintext;
                NSString *tmpfile = [NSString stringWithFormat:@"/tmp/.mm.%d.plist",getpid()];
                
                /* we dont want any trailing 0x00 bytes as this confuses GNUStep */
                size_t len = strnlen((void *)data.bytes, (size_t)data.length);
                data = [data subdataWithRange:NSMakeRange(0,len) ];
                
                [data writeToFile:tmpfile atomically:YES];
                NSDictionary *licDict = [NSDictionary dictionaryWithContentsOfFile:tmpfile];
                if(licDict == NULL)
                {
                    fprintf(stderr,"Error: can not read legacy license file %s\n",filename.UTF8String);
                }
                else
                {
                    NSLog(@"License read: %@",licDict);
                    
                    
                    NSString *licenseOwner      = licDict[@"license-name"];
                    NSString *licenseNumber     = licDict[@"license-number"];
                    NSDictionary *features      = licDict[@"features"];
                    
                    NSString *expiry            = licDict[@"expiry"];
                    NSString *hwSerial          = licDict[@"serial"];

                    BOOL featureEnabled_billing = NO;
                    BOOL featureEnabled_core = NO;
                    BOOL featureEnabled_emiucp = NO;
                    BOOL featureEnabled_gsmmap = NO;
                    BOOL featureEnabled_http = NO;
                    BOOL featureEnabled_httpHlr = NO;
                    BOOL featureEnabled_logging = NO;
                    BOOL featureEnabled_m2pa = NO;
                    BOOL featureEnabled_m3ua = NO;
                    BOOL featureEnabled_mofwd = NO;
                    BOOL featureEnabled_mtp3 = NO;
                    BOOL featureEnabled_quota = NO;
                    BOOL featureEnabled_rerouter = NO;
                    BOOL featureEnabled_sccp = NO;
                    BOOL featureEnabled_sctp = NO;
                    BOOL featureEnabled_smpp = NO;
                    BOOL featureEnabled_smsc = NO;
                    BOOL featureEnabled_smsproxy = NO;
                    BOOL featureEnabled_tcap = NO;
                    BOOL featureEnabled_udp = NO;
                    BOOL featureEnabled_isupfwd = NO;
                    BOOL featureEnabled_wappush = NO;

#define CHECK_FEATURE(featureName,featureVar) \
                    { \
                        NSDictionary *d = features[featureName]; \
                        if(d) \
                        { \
                            id var =  d[@"enable"]; \
                            if([var isKindOfClass:[NSNumber class]]) \
                            { \
                                featureVar =  [((NSNumber *)var) boolValue]; \
                            } \
                            else if([var isKindOfClass:[NSString class]]) \
                            { \
                                NSString *s = (NSString *)var; \
                                if([s isEqualToString:@"YES"] || [s isEqualToString:@"true"] || [s isEqualToString:@"1"]) \
                                { \
                                    featureVar =  YES; \
                                } \
                            }\
                        } \
                    }
                    
                    CHECK_FEATURE(@"billing",featureEnabled_billing);
                    CHECK_FEATURE(@"core",featureEnabled_core);
                    CHECK_FEATURE(@"emiucp",featureEnabled_emiucp);
                    CHECK_FEATURE(@"gsmmap",featureEnabled_gsmmap);
                    CHECK_FEATURE(@"http",featureEnabled_http);
                    CHECK_FEATURE(@"http-hlr",featureEnabled_httpHlr);
                    CHECK_FEATURE(@"logging",featureEnabled_logging);
                    CHECK_FEATURE(@"m2pa",featureEnabled_m2pa);
                    CHECK_FEATURE(@"m3ua",featureEnabled_m3ua);
                    CHECK_FEATURE(@"mofwd",featureEnabled_mofwd);
                    CHECK_FEATURE(@"mtp3",featureEnabled_mtp3);
                    CHECK_FEATURE(@"quota",featureEnabled_quota);
                    CHECK_FEATURE(@"rerouter",featureEnabled_rerouter);
                    CHECK_FEATURE(@"sccp",featureEnabled_sccp);
                    CHECK_FEATURE(@"sctp",featureEnabled_sctp);
                    CHECK_FEATURE(@"smpp",featureEnabled_smpp);
                    CHECK_FEATURE(@"smsc",featureEnabled_smsc);
                    CHECK_FEATURE(@"tcap",featureEnabled_tcap);
                    CHECK_FEATURE(@"udp",featureEnabled_udp);
                    CHECK_FEATURE(@"isupfwd",featureEnabled_isupfwd);
                    CHECK_FEATURE(@"wappush",featureEnabled_wappush);

                    CHECK_FEATURE(@"proxy",featureEnabled_smsproxy);
                    CHECK_FEATURE(@"smsproxy",featureEnabled_smsproxy);
#undef CHECK_FEATURE
                    

                    UMLicenseProduct *smsc          = [[UMLicenseProduct alloc]initWithName:@"smsc"];
                    UMLicenseProduct *smsproxy      = [[UMLicenseProduct alloc]initWithName:@"smsproxy"];

                    UMLicense *lic = [[UMLicense alloc]init];

                    UMSignedLicense *slicense       = [[UMSignedLicense alloc]init];
                    lic.licenseType                 = @"permanent";
                    slicense.license                = lic;

#define  CONDITIONAL_ADD_PRODUCT_ALL(name,flag) \
                    if (flag) \
                    { \
                        [smsc addFeatureWithName:name]; \
                        [smsproxy addFeatureWithName:name]; \
                    }
                    CONDITIONAL_ADD_PRODUCT_ALL(@"core",featureEnabled_core);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"sctp",featureEnabled_sctp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"m2pa",featureEnabled_m2pa);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"mtp3",featureEnabled_mtp3);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"m3ua",featureEnabled_m3ua);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"sccp",featureEnabled_sccp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"tcap",featureEnabled_tcap);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"gsmmap",featureEnabled_gsmmap);

                    CONDITIONAL_ADD_PRODUCT_ALL(@"http",featureEnabled_http);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"http-hlr",featureEnabled_httpHlr);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"mofwd",featureEnabled_mofwd);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"emiucp",featureEnabled_emiucp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"billing",featureEnabled_billing);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"logging",featureEnabled_logging);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"quota",featureEnabled_quota);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"smpp",featureEnabled_smpp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"udp",featureEnabled_udp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"isupfwd",featureEnabled_isupfwd);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"wappush",featureEnabled_wappush);

#undef CONDITIONAL_ADD_PRODUCT_ALL
                    
                    if(featureEnabled_smsc)
                    {
                        [smsc addFeatureWithName:@"smsc"];
                        [lic addProduct:smsc];
                    }
                    if(featureEnabled_smsproxy)
                    {
                        [smsc addFeatureWithName:@"smsproxy"];
                        [lic addProduct:smsproxy];
                    }

                    NSDate *expiration = [expiry dateValue];

                    if(expiration)
                    {
                        lic.licenseType = @"temporary";
                    }
                    else
                    {
                        lic.licenseType = @"permanent";
                    }
                
                    lic.licenseOwner = licenseOwner;
                    lic.licenseSerialNumber = licenseNumber;
                    lic.licenseExpiration =  expiration;

                    UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                    rest.lockedToLegacySerial = hwSerial;
                    [lic addRestriction: rest];
                    slicense.license = lic;
                    if(outputLicenseFileName==NULL)
                    {
                        outputLicenseFileName = [NSString stringWithFormat:@"%@.license",slicense.license.licenseSerialNumber];
                    }
                    if(signatureKey)
                    {
                        [slicense signLicenseWithRSAPublicKey:signatureKey];
                    }
                    if(encryptionKey)
                    {
                        [slicense encryptLicenseWithRSAPublicKey:encryptionKey];
                    }
                    NSData *data = [slicense berEncoded];
                    fprintf(stderr,"writing new license to %s",outputLicenseFileName.UTF8String);
                    [data writeToFile:outputLicenseFileName atomically:YES];
                }
            }
        }
        [licdir decryptLicenses];
        [licdir validateSignatures];
        NSString *d = licdir.description;
        fprintf(stdout,"%s",d.UTF8String);
    }
    return 0;
}
