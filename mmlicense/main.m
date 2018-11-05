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
licenseFeatures[name] = @{@"enable": @"YES"}; \
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
		NSString *encryptionKey = g_defaultEncryptionKey;
		NSString *signatureKey = g_defaultSignKey;
		BOOL verbose=NO;
		
		if(params[@"verbose"])
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
			NSArray *demos = params[@"demo"];
			for(NSString *demo in demos)
			{
				int days  = [demo intValue];
				
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
		if(params[@"renew-url"])
		{
			NSArray *urls = params[@"renew-url"];
			for(NSString *url in urls)
			{
				mmlicense.licenseType = @"renewing";
				mmlicense.licenseRenewUrl = url;
			}
		}
		if(params[@"renew-address"])
		{
			NSArray *nrs = params[@"renew-address"];
			for(NSString *nr in nrs)
			{
				mmlicense.licenseType = @"renewing";
				mmlicense.licenseRenewAddress= nr;
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
			doLegacy = YES;
			if(verbose)
			{
				NSLog(@"legacy=yes");
			}
		}

		if(params[@"smpp"])
		{
			ADD_PRODUCT_ALL(@"smpp");
		}
		
		if(params[@"emi-ucp"])
		{
			ADD_PRODUCT_ALL(@"emi-ucp");
		}
		if(params[@"m3ua"])
		{
			ADD_PRODUCT_ALL(@"m3ua");
		}
		if(params[@"http"])
		{
			ADD_PRODUCT_ALL(@"http");
		}
		if(params[@"http-hlr"])
		{
			ADD_PRODUCT_ALL(@"http-hlr");
		}
		if(params[@"mofwd"])
		{
			ADD_PRODUCT_ALL(@"mofwd");
		}
		if(params[@"quota"])
		{
			ADD_PRODUCT_ALL(@"quota");
		}
		if(params[@"interworking"])
		{
			ADD_PRODUCT_ALL(@"interworking");
		}
		if(params[@"udp"])
		{
			ADD_PRODUCT_ALL(@"udp");
		}

		if(params[@"expiration"])
		{
			NSArray *expirations = params[@"expiration"];
			for(NSString *expiration in expirations)
			{
				NSDateFormatter *formatter;
				expirationDate = [formatter dateFromString:expiration];
				mmlicense.licenseType = @"temporary";
			}
		}
		if(params[@"license-number"])
		{
			NSArray *lns = params[@"license-number"];
			for(NSString *ln in lns)
			{
				licenseNumber = ln;
			}
		}
		if(params[@"license-name"])
		{
			
			NSArray *lns = params[@"license-name"];
			for(NSString *ln in lns)
			{
				licenseName = ln;
			}
		}
		if(params[@"smsc"])
		{
			licenseFeatures[@"smsc"] = @{@"enable": @"YES"};
			[mmlicense addProduct:smsc];

		}
		if(params[@"smsproxy"])
		{
			licenseFeatures[@"smsproxy"] = @{@"enable": @"YES"};
			[mmlicense addProduct:smsproxy];
		}
		if(params[@"estp"])
		{
			licenseFeatures[@"estp"] = @{@"enable": @"YES"};
			[mmlicense addProduct:estp];
		}
		if(params[@"ss7firewall"])
		{
			licenseFeatures[@"ss7firewall"] = @{@"enable": @"YES"};
			[mmlicense addProduct:ss7firewall];
		}
		if(params[@"cnamserver"])
		{
			licenseFeatures[@"cnamserver"] = @{@"enable": @"YES"};
			[mmlicense addProduct:cnamserver];
		}

		if(params[@"rerouter"])
		{
			licenseFeatures[@"rerouter"] = @{@"enable": @"YES"};
			[mmlicense addProduct:rerouter];
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
				NSString *licenseInstallFileName = @"/etc/messagemover/license.bin";
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
			[slicense signLicenseWithRSAPublicKey:signatureKey];

			NSString *licenseFileName = [NSString stringWithFormat:@"%@.license",slicense.license.licenseSerialNumber];
			if(encryptionKey)
			{
				[slicense encryptLicenseWithRSAPublicKey:encryptionKey];
			}
			NSData *data = [slicense berEncoded];
			NSLog(@"writing new license to %@",licenseFileName);
			[data writeToFile:licenseFileName atomically:YES];
		}
	}
    return 0;
}

