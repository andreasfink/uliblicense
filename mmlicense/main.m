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

NSString *g_defaultEncryptionKey = @"-----BEGIN PUBLIC KEY-----"
@"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAupJJTHXBDeMIdeYnezgD"
@"9/eHhapOFISNWeA1otheCdIJu42TOoTubh3X7527OTfv2FBr+9h8snqIDU7fsyKn"
@"Y6Lb3t7GA6K5Q5hctHlGf659xRmCJ2dTZqK/NJnr41nAxLst/odJm7kF4Z1k65iU"
@"Fztxkv8Eodhkolr25AnlYIKntU9c3YxpKovJmOI6iypYlZvZSzUopIfOnRH+qpY2"
@"A2u0UVjSLhZgfjDFjA8r/hw0sUYFmsi1Z3FeLBiG9NIcb4C6aju28eAN5qRkI8ED"
@"8Gm3W/ayXEvN5BDHQa0yJ+/TaghcmpkaxVebYJeYMJkBeH3MfKt47dRGHfkInDQW"
@"FXixfPOzfgdrvO2VkmpNXzTStpOTWnwVYnC5Folxgs02zofwiMQVF6kKePwHcF6m"
@"EkOaFUWslpKLjbNRZ5Nyo7OQ9K3Fww/YSumnMsR6pYr5yWav18MtYWae2rS+S7Yu"
@"lMpIP2LjQZLlmtj+BJdqFlC8zKtTlsnT++fltBfXnb3svzqmeyfWNyB6ksrYre5W"
@"P1V8myuYzXbl7atnKtg3YTq0yO0GuaXr6UcJ0YF4zIvs123OzTQ2wt0a5uvl/Nxa"
@"X8xLA86tO87pZBJhBDvpqg05LTWSihjfffWMtW3qHDkLoP3qNsTs/E5shVT9t1G9"
@"mIUKUkP5JO101V5JT9b7uWcCAwEAAQ=="
@"-----END PUBLIC KEY-----";


NSString *g_defaultSignKey = @"-----BEGIN PUBLIC KEY-----"
 @"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsxnayLqYwH+QbTMdJB1j"
 @"u1glztLXnuoMhQkmojqLm0SllGgmxOWGDXyJa+XEdxv1ctnVRju23kPzSqVKK03U"
 @"YMi1FE+6q4ZqYOxlSgIBg/HJBpz6dYKxHe4CHnMtaXbnjVvBARqYlIZtj+4b3sk3"
 @"0Jmge8J3N32Q/6ke96YdT04cbJAJeaawKGEvbolj6oel/iXrcHyFSQ6vd2sioCaV"
 @"TDGE5T7ComIchpk/O/sUuMG+4DoO+XfJ6lmOIFxk+A1Ic0PGB7McfslCveSN1u4Q"
 @"HBAY4Jxsp54n5EcclC9fZdTWueO0jjroGimRi5FkG8RfhGcdaCRDgF3Zr+3bJaDf"
 @"qAwVDFf5TBnDZe/W5VgwRojTQdBnSHkTb0V6EfZ2s6u8dnf0LYM6ZytUzJ+0cbJE"
 @"f5v5BW1nv+h0+qeP2HJMsScQeUR26eAoe/lqqD66v7mTW+l6KXpy7tWyW5Bnq2va"
 @"XvD/eE/eRVAiEAd8zLdJdfVuD7EzZGOl7770Y1qihW59oIzBJB/2VH4zTGlZOiZE"
 @"YKSFe9bvEa3uNMbH3o4AaEC7403YzHpnrFLi0PE4szWXmSlLIrVhgdYb9Vhft8bk"
 @"zSJ5s4jHmGCut+agwOz74GC8c4t9B7GHrT3OITrhqvM3DNaAOzg3YzCBU/hIVVkS"
 @"0kmYzR/32O06hkdMGEk9fA8CAwEAAQ=="
@"-----END PUBLIC KEY-----";

int main(int argc, const char * argv[])
{
	NSString *email = NULL;
	
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

	
	@autoreleasepool
	{
		NSDictionary *appDefinition = @
		{
			@"version" : @(VERSION),
			@"executable" : @"mmlicense",
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
											   @"name"  : @"output",
											   @"short" : @"-o",
											   @"long"  : @"--output-file",
											   @"argument" : @"filename",
											   @"help"  : @"output file",
											   },
										   @{
											   @"name"  : @"install",
											   @"short" : @"-i",
											   @"long"  : @"--install",
											   @"help"  : @"install the license file",
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
											   },
										   @{
											   @"name"  : @"legacy",
											   @"short" : @"-w",
											   @"long"  : @"--legacy",
											   @"help"  : @"write legacy license file",
											   },
										   @{
											   @"name"  : @"demo",
											   @"short" : @"-d",
											   @"long"  : @"--demo",
											   @"argument" : @"validity in days",
											   @"help"  : @"create expiring demo license ",
											   },
										   @{
											   @"name"  : @"renew-url",
											   @"short" : @"-r",
											   @"long"  : @"--renew-url",
											   @"argument" : @"url",
											   @"help"  : @"url to automatically renew license",
											   },
										   @{
											   @"name"  : @"expiration",
											   @"short" : @"-e",
											   @"long"  : @"--expiration",
											   @"argument" : @"'yyy-mm-dd hh:mm:ss.xxxxxx'",
											   @"help"  : @"timestamp of expiration date",
											   },
										   @{
											   @"name"  : @"license-name",
											   @"short" : @"-n",
											   @"long"  : @"--license-name",
											   @"argument" : @"owner of license",
											   @"help"  : @"set the license name",
											   },
										   @{
											   @"name"  : @"license-number",
											   @"short" : @"-n",
											   @"long"  : @"--license-number",
											   @"argument" : @"number of license",
											   @"help"  : @"set the license number",
											   },
										   @{
											   @"name"  : @"smsc",
											   @"short" : @"",
											   @"long"  : @"--smsc",
											   @"help"  : @"enable product SMSC",
											   },
										   @{
											   @"name"  : @"smpp",
											   @"short" : @"",
											   @"long"  : @"--smpp",
											   @"help"  : @"enable SMPP protocol",
											   },
										   @{
											   @"name"  : @"emi-ucp",
											   @"short" : @"",
											   @"long"  : @"--emi-ucp",
											   @"help"  : @"enable EMI/UCP protocol",
											   },
										   @{
											   @"name"  : @"http",
											   @"short" : @"",
											   @"long"  : @"--http",
											   @"help"  : @"enable HTTP submission protocol",
											   },
										   @{
											   @"name"  : @"http-hlr",
											   @"short" : @"",
											   @"long"  : @"--http-hlr",
											   @"help"  : @"enable HTTP HLR query protocol",
											   },
										   @{
											   @"name"  : @"mofwd",
											   @"short" : @"",
											   @"long"  : @"--mofwd",
											   @"help"  : @"enable MO-ForwardSM option",
											   },
										   @{
											   @"name"  : @"quota",
											   @"short" : @"",
											   @"long"  : @"--quota",
											   @"help"  : @"enable Quota option",
											   },
										   @{
											   @"name"  : @"interworking",
											   @"short" : @"",
											   @"long"  : @"--interworking",
											   @"help"  : @"enable interworking option",
											   },
										   @{
											   @"name"  : @"rerouter",
											   @"short" : @"",
											   @"long"  : @"--rerouter",
											   @"help"  : @"enable rerouter option",
											   },
										   @{
											   @"name"  : @"udp",
											   @"short" : @"",
											   @"long"  : @"--udp",
											   @"help"  : @"enable udp option",
											   },
										   @{
											   @"name"  : @"smsproxy",
											   @"short" : @"",
											   @"long"  : @"--smsproxy",
											   @"help"  : @"enable product SMSProxy",
											   },
										   @{
											   @"name"  : @"cnam-server",
											   @"short" : @"",
											   @"long"  : @"--cnam-server",
											   @"help"  : @"enable product CNAM-Server",
											   },
										   @{
											   @"name"  : @"ss7firewall",
											   @"short" : @"",
											   @"long"  : @"--ss7firewall",
											   @"help"  : @"enable product SS7 Firewall",
											   },
										   @{
											   @"name"  : @"estp",
											   @"short" : @"",
											   @"long"  : @"--estp",
											   @"help"  : @"enable product ESTP",
											   }];

		UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
																		   appDefinition:appDefinition
																					argc:argc
																					argv:argv];

		[_commandLine handleStandardArguments];
		NSDictionary *params = _commandLine.params;
		
		UMLicenseDirectory *licdir = [[UMLicenseDirectory alloc]init];
		NSString *encryptionKey = g_defaultEncryptionKey;
		NSString *signatureKey = g_defaultSignatureKey;
		NSString *outputLicenseFileName = NULL;
		BOOL verbose=NO;
		
		if(params@"verbose")
		{
			verbose = YES;
		}
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

		
		
		if(params[@"email"])
		{
			NSArray *emails = params[@"email"];
			if(emails.count > 0)
			{
				email = emails[0];
			}
		}

		if(params[@"output"])
		{
			NSArray *filenames = params[@"output"];
			for(NSString *filename in filenames)
			{
				licenseFileName = filename;
			}
		}
		if(params[@"serial"])
		{
			NSArray *serials = params[@"output"];
			for(NSString *serial in serials)
			{
				serialNumber = serial;
			}
		}
		if(params[@"demo"])
		{
			NSArray *serials = params[@"output"];
			for(NSString *serial in serials)
			{
				serialNumber = serial;
			}
		}
		if(params[@"install"])
		{
			doInstall = YES;
			if(verbose)
			{
				NSLog(@"doInstall=yes");
			}
		}
		if(params[@"legacy"])
		{
			
		}
		if(params[@"file"])
		{
			
		}
		if(params[@"serial"])
		{
			
		}
		if(params[@"demo"])
		{
			
		}
		if(params[@"renew-url"])
		{
			
		}
		if(params[@"expiration"])
		{
			
		}
		if(params[@"license-number"])
		{
			
		}
		if(params[@"license-name"])
		{
			
		}
		if(params[@"smsc"])
		{
			
		}
		if(params[@"smsproxy"])
		{
			
		}
		if(params[@"smsc"])
		{
			
		}
		if(params[@"ss7firewall"])
		{
			
		}
		if(params[@"cnamserver"])
		{
			
		}

		NSMutableDictionary     *licenseFeatures	= [[NSMutableDictionary alloc]init];
		NSMutableDictionary     *licenseFile 		= [[NSMutableDictionary alloc]init];
		
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

