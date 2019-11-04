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
	UMLicenseProduct *smsfirewall   = [[UMLicenseProduct alloc]initWithName:@"smsfirewall"];
	UMLicenseProduct *cnam_server    = [[UMLicenseProduct alloc]initWithName:@"cnam-server"];
	UMLicenseProduct *simproxy    	= [[UMLicenseProduct alloc]initWithName:@"simproxy"];
	UMLicenseProduct *hlrclient    	= [[UMLicenseProduct alloc]initWithName:@"hlrclient"];
	UMLicenseProduct *eirproxy    	= [[UMLicenseProduct alloc]initWithName:@"eirproxy"];
	UMLicenseProduct *diameter_dra  = [[UMLicenseProduct alloc]initWithName:@"diameter-routing-agent"];
	UMLicenseProduct *diameter_dea  = [[UMLicenseProduct alloc]initWithName:@"diameter-edge-agent"];
	UMLicenseProduct *map_api 		= [[UMLicenseProduct alloc]initWithName:@"map-api-server"];
	UMLicenseProduct *camel_api 	= [[UMLicenseProduct alloc]initWithName:@"camel-api-server"];
	UMLicenseProduct *diameter_api	= [[UMLicenseProduct alloc]initWithName:@"diameter-api-server"];

#define  ADD_PRODUCT_ALL(name) \
licenseFeatures[name] = @{@"enable": @"YES"}; \
[smsc addFeatureWithName:name]; \
[smsproxy addFeatureWithName:name]; \
[rerouter addFeatureWithName:name]; \
[estp addFeatureWithName:name]; \
[ss7firewall addFeatureWithName:name]; \
[smsfirewall addFeatureWithName:name]; \
[cnam_server addFeatureWithName:name]; \
[simproxy addFeatureWithName:name]; \
[hlrclient addFeatureWithName:name]; \
[diameter_dra addFeatureWithName:name]; \
[diameter_dea addFeatureWithName:name]

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
    [ss7firewall addFeatureWithName:@"ss7screening"];
    [ss7firewall addFeatureWithName:@"ss7alwaysmatch"];
    [ss7firewall addFeatureWithName:@"ss7nevermatch"];
    [ss7firewall addFeatureWithName:@"ss7monitor"];
    [ss7firewall addFeatureWithName:@"ss7smsmonitor"];
	[cnam_server addFeatureWithName:@"cnam-server"];
	[simproxy addFeatureWithName:@"simproxy"];
	[hlrclient addFeatureWithName:@"hlrclient"];
	[eirproxy addFeatureWithName:@"eirproxy"];
	[diameter_dra addFeatureWithName:@"diameter-routing-agent"];
	[diameter_dea addFeatureWithName:@"diameter-edge-agent"];

	NSString *licenseFileName = @"license.bin";
	licenseFeatures[@"core"] = @{@"enable": @"YES"};
	licenseFeatures[@"sctp"] = @{@"enable": @"YES"};
	licenseFeatures[@"m2pa"] = @{@"enable": @"YES"};
	licenseFeatures[@"mtp3"] = @{@"enable": @"YES"};
	licenseFeatures[@"sccp"] = @{@"enable": @"YES"};
	licenseFeatures[@"tcap"] = @{@"enable": @"YES"};
	licenseFeatures[@"gsmmap"] = @{@"enable": @"YES"};
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
                                               @"name"  : @"report-url",
                                               @"short" : @"-r",
                                               @"long"  : @"--report-url",
                                               @"argument" : @"url",
                                               @"help"  : @"url to report license",
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
                                               @"name"  : @"serial",
                                               @"long"  : @"--serial",
                                               @"argument" : @"serial-number",
                                               @"help"  : @"set the hardware serial number lock",
                                               },
                                           @{
                                               @"name"  : @"cpu-id",
                                               @"long"  : @"--cpu-id",
                                               @"argument" : @"cpu-id",
                                               @"help"  : @"set the hardware cpu-id lock",
                                               },
                                           @{
                                               @"name"  : @"mac-addr",
                                               @"long"  : @"--mac-addr",
                                               @"argument" : @"mac-addr",
                                               @"help"  : @"set the hardware mac-addr lock",
                                               },
                                           @{
                                               @"name"  : @"ip-addr",
                                               @"long"  : @"--ip-addr",
                                               @"argument" : @"ip-address",
                                               @"help"  : @"set the hardware ip-address lock",
                                               },
                                           @{
                                               @"name"  : @"os",
                                               @"long"  : @"--os",
                                               @"argument" : @"osname",
                                               @"help"  : @"set the operating sytem lock",
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
                                               @"name"  : @"m2pa",
                                               @"short" : @"",
                                               @"long"  : @"--m2pa",
                                               @"help"  : @"enable M2PA protocol",
                                               },
                                           @{
                                                @"name"  : @"m3ua",
                                                @"short" : @"",
                                                @"long"  : @"--m3ua",
                                                @"help"  : @"enable M3UA protocol",
                                           },
                                           @{
                                               @"name"  : @"mtp3",
                                               @"short" : @"",
                                               @"long"  : @"--mtp3",
                                               @"help"  : @"enable MTP3 Instance",
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
											   @"name"  : @"diameter",
											   @"long"  : @"--diameter",
											   @"help"  : @"support diameter protocol",
											   },
										   @{
											   @"name"  : @"diameter-routing-agent",
											   @"long"  : @"--diameter-routing-agent",
											   @"help"  : @"adds  diameter routing agent functionality",
											   },
										   @{
											   @"name"  : @"diameter-edge-agent",
											   @"long"  : @"--diameter-edge-agent",
											   @"help"  : @"addsdiameter edge agent functionality",
											   },
										   @{
											   @"name"  : @"estp",
											   @"short" : @"",
											   @"long"  : @"--estp",
											   @"help"  : @"enable product ESTP",
											   },
										   @{
											   @"name"  : @"hlrclient",
											   @"short" : @"",
											   @"long"  : @"--hlrclient",
											   @"help"  : @"enable product hlrclient",
											   },
										   @{
											   @"name"  : @"simproxy",
											   @"short" : @"",
											   @"long"  : @"--simproxy",
											   @"help"  : @"enable product simproxy",
											   },
										   @{
											   @"name"  : @"eirproxy",
											   @"short" : @"",
											   @"long"  : @"--eirproxy",
											   @"help"  : @"enable product EIR Proxy",
											   },
											   @{
											   @"name"  : @"map-api-server",
											   @"short" : @"",
											   @"long"  : @"--map-api-server",
											   @"help"  : @"enable GSMMAP API",
											   },
											   @{
											   @"name"  : @"camel-api-server",
											   @"short" : @"",
											   @"long"  : @"--camel-api-server",
											   @"help"  : @"enable CAMEL API",
											   },
											   @{
											   @"name"  : @"diameter-api-server",
											   @"short" : @"",
											   @"long"  : @"--diameter-api-server",
											   @"help"  : @"enable Diameter API",
											   },];

		UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
																		   appDefinition:appDefinition
																					argc:argc
																					argv:argv];

		[_commandLine handleStandardArguments];
		NSDictionary *params = _commandLine.params;
        NSString *encryptionKey = NULL;
        NSString *signatureKey = NULL;
		BOOL verbose=NO;

        UMLicenseRestrictionList *licenseRestrictions = [[UMLicenseRestrictionList alloc]init];

		if(params[@"verbose"])
		{
			verbose = YES;
		}
        NSArray *a = params[@"encryption-key"];
		if(a.count  > 0)
		{
			for(NSString *filename in a)
			{
				NSError *err =NULL;;
				
				NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
				if(key)
				{
					encryptionKey = key;
				}
			}
		}
        else
        {
            NSError *err = NULL;
            encryptionKey = [NSString stringWithContentsOfFile:@"/opt/uliblicense/encryption.key" encoding:NSUTF8StringEncoding error:&err];
            if(err)
            {
                NSLog(@"%@",err);
            }
        }

        a = params[@"signature-key"];
		if(a.count > 0)
		{
			for(NSString *filename in a)
			{
				NSError *err =NULL;
				NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(err)
                {
                    NSLog(@"%@",err);
                }
				if(key)
				{
					signatureKey = key;
				}
			}
		}
        else
        {
            NSError *err = NULL;
            signatureKey = [NSString stringWithContentsOfFile:@"/opt/uliblicense/sign.key" encoding:NSUTF8StringEncoding error:&err];
            if(err)
            {
                NSLog(@"%@",err);
            }
        }
		
		
		if(params[@"email"])
		{
			NSArray *emails = params[@"email"];
			if(emails.count > 0)
			{
				email = emails[0];
                mmlicense.licenseEmail = email;
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

        if(params[@"cpu-id"])
        {
            NSArray *entries = params[@"cpu-id"];
            for(NSString *entry in entries)
            {
                UMLicenseRestriction *lr = [[UMLicenseRestriction alloc]init];
                lr.lockedToCpuId = entry;
                [licenseRestrictions addRestriction:lr];
            }
        }

        if(params[@"mac-addr"])
        {
            NSArray *entries = params[@"mac-addr"];
            for(NSString *entry in entries)
            {
                UMLicenseRestriction *lr = [[UMLicenseRestriction alloc]init];
                lr.lockedToMacAddress = entry;
                [licenseRestrictions addRestriction:lr];
            }
        }
        if(params[@"ip-addr"])
        {
            NSArray *entries = params[@"ip-addr"];
            for(NSString *entry in entries)
            {
                UMLicenseRestriction *lr = [[UMLicenseRestriction alloc]init];
                lr.lockedToIp= entry;
                [licenseRestrictions addRestriction:lr];
            }
        }
        if(params[@"os"])
        {
            NSArray *entries = params[@"os"];
            for(NSString *entry in entries)
            {
                UMLicenseRestriction *lr = [[UMLicenseRestriction alloc]init];
                lr.lockedToOperatingSystem= entry;
                [licenseRestrictions addRestriction:lr];
            }
        }
        if(params[@"serial"])
        {
            NSArray *entries = params[@"serial"];
            for(NSString *entry in entries)
            {
                licenseFile[@"serial"] = entry;
                UMLicenseRestriction *lr = [[UMLicenseRestriction alloc]init];
                lr.lockedToSerial= entry;
                [licenseRestrictions addRestriction:lr];
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
                mmlicense.licenseExpiration = expirationDate;
			}
		}
		if(params[@"renew-url"])
		{
			NSArray *urls = params[@"renew-url"];
			for(NSString *url in urls)
			{
				mmlicense.licenseType = @"renewing";
                mmlicense.licenseRenewUrl = url;
                mmlicense.licenseRenewTimerMin = @(7*24*60*60); /* min once a week */
                mmlicense.licenseRenewTimerMax = @(31*24*60*60); /* max one per month */
                mmlicense.licenseRenewAddress = @"+41587079921";
			}
		}
        if(params[@"report-url"])
        {
            NSArray *urls = params[@"report-url"];
            for(NSString *url in urls)
            {
                mmlicense.licenseReportUrl = url;
                mmlicense.licenseReportAddress = @"+41587079922";
                mmlicense.licenseReportTimer = @(7*24*60*60); /* report once a week */
            }
        }
        else
        {
            mmlicense.licenseReportUrl = @"https://license.messagemover.com/report.php";
            mmlicense.licenseReportAddress = @"+41587079922";
            mmlicense.licenseReportTimer = @(7*24*60*60); /* report once a week */
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
		if(params[@"diameter"])
		{
			ADD_PRODUCT_ALL(@"diameter");
		}
        if(params[@"tcap"])
        {
            ADD_PRODUCT_ALL(@"tcap");
        }
        if(params[@"gsmmap"])
        {
            ADD_PRODUCT_ALL(@"gsmmap");
        }
        if(params[@"m2pa"])
        {
            ADD_PRODUCT_ALL(@"m2pa");
        }
        if(params[@"mtp3"])
        {
            ADD_PRODUCT_ALL(@"mtp3");
        }

		if(params[@"expiration"])
		{
			NSArray *expirations = params[@"expiration"];
			for(NSString *expiration in expirations)
			{
                expirationDate = [NSDate dateWithStandardDateString:expiration];
                if(expirationDate==NULL)
                {
                    fprintf(stderr,"Can not interpret date '%s'. Please use format 'yyyy-MM-dd HH:mm:ss.SSSS'\n",expiration.UTF8String);
                    exit(-1);
                }
				mmlicense.licenseType = @"temporary";
                mmlicense.licenseExpiration = expirationDate;
			}
		}
		if(params[@"license-number"])
		{
			NSArray *lns = params[@"license-number"];
			for(NSString *ln in lns)
			{
				licenseNumber = ln;
                mmlicense.licenseSerialNumber = licenseNumber;
			}
		}
		if(params[@"license-name"])
		{
			
			NSArray *lns = params[@"license-name"];
			for(NSString *ln in lns)
			{
				licenseName = ln;
                mmlicense.licenseOwner = licenseName;
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
		if(params[@"ss7firewall"])
		{
			licenseFeatures[@"ss7firewall"] = @{@"enable": @"YES"};
			[mmlicense addProduct:ss7firewall];
		}
		if(params[@"smsfirewall"])
		{
			licenseFeatures[@"smsfirewall"] = @{@"enable": @"YES"};
			[mmlicense addProduct:smsfirewall];
		}

		if(params[@"cnam-server"])
		{
			licenseFeatures[@"cnam-server"] = @{@"enable": @"YES"};
			[mmlicense addProduct:cnam_server];
		}
		if(params[@"simproxy"])
		{
			licenseFeatures[@"simproxy"] = @{@"enable": @"YES"};
			[mmlicense addProduct:simproxy];
		}
		if(params[@"hlrclient"])
		{
			licenseFeatures[@"hlrclient"] = @{@"enable": @"YES"};
			[mmlicense addProduct:simproxy];
		}
		if(params[@"eirproxy"])
		{
			licenseFeatures[@"eirproxy"] = @{@"enable": @"YES"};
			[mmlicense addProduct:simproxy];
		}
		if(params[@"rerouter"])
		{
			licenseFeatures[@"rerouter"] = @{@"enable": @"YES"};
			[mmlicense addProduct:rerouter];
		}
		if(params[@"diameter-edge-agent"])
		{
			[diameter_dea addFeatureWithName:@"diameter-edge-agent"];
			[estp addFeatureWithName:@"diameter-edge-agent"];
			[diameter_dea addFeatureWithName:@"diameter"];
			[estp addFeatureWithName:@"diameter"];
			[mmlicense addProduct:diameter_dea];
		}
		if(params[@"diameter-routing-agent"])
		{
			[diameter_dra addFeatureWithName:@"diameter-routing-agent"];
			[estp addFeatureWithName:@"diameter-routing-agent"];
			[diameter_dra addFeatureWithName:@"diameter"];
			[estp addFeatureWithName:@"diameter"];
			[mmlicense addProduct:diameter_dra];
		}

		if(params[@"map-api-server"])
		{
			[map_api addFeatureWithName:@"map-api-server"];
			[estp addFeatureWithName:@"map-api-server"];
			[mmlicense addProduct:map_api];
		}
		if(params[@"camel-api-server"])
		{
			[camel_api addFeatureWithName:@"camel-api-server"];
			[estp addFeatureWithName:@"camel-api-server"];
			[mmlicense addProduct:camel_api];
		}

		if(params[@"diameter-api-server"])
		{
			[diameter_api addFeatureWithName:@"diameter-api-server"];
			[estp addFeatureWithName:@"diameter-api-server"];
			[mmlicense addProduct:diameter_api];
		}



		if(params[@"estp"])
		{
			licenseFeatures[@"estp"] = @{@"enable": @"YES"};
			[estp addFeatureWithName:@"estp"];
			[mmlicense addProduct:estp];
		}

		licenseFile[@"features"] = licenseFeatures;


        mmlicense.licenseRestrictions = licenseRestrictions;

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

