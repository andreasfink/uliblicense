//
//  UMLicenseDirectory.m
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import "UMLicenseDirectory.h"
#import "UMLicense.h"
#import "UMSignedLicense.h"
#import "UMLicenseProductFeature.h"
#import "UMLicenseFile.h"
#import "UMLicenseRestrictionList.h"
#import "UMLicenseRestriction.h"
@implementation UMLicenseDirectory

- (void)genericInitialisation
{
    _licenseFiles = [[NSMutableArray alloc] init];
    _licenseDecryptionKeys = [[NSMutableArray alloc] init];
    _licenseSignatureKeys = [[NSMutableArray alloc] init];
    _lock = [[UMMutex alloc]initWithName:@"umlicense-lock"];
    _licenseDirectory = @"/etc/umlicense/";
    _timer = [[UMTimer alloc]initWithTarget:self
                                   selector:@selector(refreshLicenses)
                                     object:NULL
                                    seconds:5*60 /* every 5 minutes we check if there's any licenses to be potentially updated */
                                       name:@"license-check-timer"
                                    repeats:YES];
}

- (UMLicenseDirectory *)init
{
    self = [super init];
    if(self)
    {
        [self genericInitialisation];
    }
    return self;
}

- (UMLicenseDirectory *)initWithPath:(NSString *)path
{
    self = [super init];
    if(self)
    {
        [self genericInitialisation];
        [self scanDirectoryForLicenseFiles:path];
    }
    return self;
}

- (void)startAutoRefresh
{
    [_timer start];
}

-(void)stopAutoRefresh
{
    [_timer stop];
}

- (void)scanDirectoryForLicenseFiles:(NSString *)path
{
    if(path==NULL)
    {
        path = _licenseDirectory;
    }
    if(_debug)
    {
        fprintf(stderr,"DEBUG: scanDirectoryForLicenseFiles('%s'\n",path.UTF8String);
    }

    [_lock lock];
    NSFileManager *mgr = [NSFileManager defaultManager];
    for (NSString *filePath in [mgr enumeratorAtPath:path])
    {
        NSError *err = nil;
        NSString *fullPath = [path stringByAppendingPathComponent:filePath];
        if(_debug)
        {
            fprintf(stderr,"DEBUG: pocessing item '%s'\n",fullPath.UTF8String);
        }
        NSDictionary *itemInfo = [mgr attributesOfItemAtPath:fullPath error:&err];
        if (itemInfo)
        {
            if ([itemInfo objectForKey:NSFileType] == NSFileTypeRegular)
            {
                if([fullPath hasSuffix:@".license"])
                {
                    UMLicenseFile *licenseFile = [[UMLicenseFile alloc]initWithFilename:fullPath debug:_debug];
                    if(licenseFile)
                    {
                        [self addLicenseFile:licenseFile];
                    }
                }
                else
                {
                    if(_debug)
                    {
                        fprintf(stderr,"DEBUG: '%s' ignored. Filename is not ending in .license\n",fullPath.UTF8String);
                    }
                }
            }
            else
            {
                if(_debug)
                {
                    fprintf(stderr,"DEBUG: '%s' ignored. Its not a regular file\n",fullPath.UTF8String);
                }

            }
        }
    }
    [_lock unlock];

}

- (void)addLicenseFile:(UMLicenseFile *)licenseFile
{
    if(licenseFile)
    {
        [_lock lock];
        [_licenseFiles addObject:licenseFile];
        [_lock unlock];
    }
}


- (void)addDecryptionKey:(NSString *)key
{
    if(key)
    {
        [_lock lock];
        [_licenseDecryptionKeys addObject:key];
        [_lock unlock];
    }
}

- (void)addSignatureVerificationKey:(NSString *)key
{
    if(key)
    {
        [_lock lock];
        [_licenseSignatureKeys addObject:key];
        [_lock unlock];
    }
}

- (void)decryptLicenses
{
    [_lock lock];

    int n = (int)_licenseFiles.count;
    for(int i=0;i<n;i++)
    {
        UMLicenseFile *licFile = _licenseFiles[i];
        UMSignedLicense *slic = licFile.signedLicense;
        
        if((slic.license == NULL) && ( slic.encryptedLicense !=NULL))
        {
            @try
            {
                [slic decryptLicenseWithKeys:[_licenseDecryptionKeys copy]];
            }
            @catch(NSException *e)
            {
                if(_debug)
                {
                    NSString *s = e.description;
                    fprintf(stderr,"DEBUG: can not decrypt license: %s\n",s.UTF8String);
                }
            }
        }
        if(slic.license == NULL)
        {
            NSLog(@"Can not decrypt licensefile %@",licFile.fullPath);
            [_licenseFiles removeObjectAtIndex:i];
            n--;
            i--;
        }
    }
    [_lock unlock];

}

- (void)validateSignatures
{
    [_lock lock];

    NSUInteger n = _licenseFiles.count;
    for(NSUInteger i=0;i<n;i++)
    {
        UMLicenseFile *licFile = _licenseFiles[i];
        UMSignedLicense *slic = licFile.signedLicense;
        
        if(![slic isSignatureValidForKeys:[_licenseSignatureKeys copy]])
        {
            NSLog(@"Invalid signature in %@",licFile.fullPath);
            [_licenseFiles removeObjectAtIndex:i];
            n--;
            i--;
        }
        
        if((slic.license == NULL) && ( slic.encryptedLicense !=NULL))
        {
            [slic decryptLicenseWithKeys:[_licenseDecryptionKeys copy]];
        }
        if(slic.license == NULL)
        {
            [_licenseFiles removeObjectAtIndex:i];
            n--;
            i--;
        }
    }
    [_lock unlock];

}

- (BOOL)validateRestrictions;
{
    [_lock lock];
    
    // Initial NO Valid
    BOOL valid = NO;
    BOOL osValid = NO;

    for(UMLicenseFile *licFile in _licenseFiles)
    {
        UMSignedLicense *slic = licFile.signedLicense;
        
        // every UMSignedLicense object has UMLicense object in .license (if its decoded)
        if((slic.license == NULL) && ( slic.encryptedLicense !=NULL))
        {
            [slic decryptLicenseWithKeys:[_licenseDecryptionKeys copy]];
        }
        
        if(slic.license == NULL)
        {
            [_licenseFiles removeObject:slic];
        }
        else
        {
        
#if defined(__APPLE__)
    #define PLATFORM_NAME "osx" // Apple OSX
#elif defined(__linux__)
    #define PLATFORM_NAME "linux" // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other    
#elif defined(__FreeBSD__)
    #define PLATFORM_NAME "FreeBSD" // FreeBSD
#elif defined(__NetBSD__)
    #define PLATFORM_NAME "NetBSD" // NetBSD
#elif defined(__OpenBSD__)
    #define PLATFORM_NAME "OpenBSD" // OpenBSD
#else
#error Unknown platform name
#endif    

            NSArray *arr_licR = slic.license.licenseRestrictions.values;
            
            // lets first go through the OS restrictions
            // we should have at least one matching records or no records at all
            int osRecCount = 0;
            for(UMLicenseRestriction *licR in arr_licR)
            {
                if(licR.lockedToOperatingSystem)
                {
                    NSString *os = licR.lockedToOperatingSystem;
					if ([os isEqualToString:@PLATFORM_NAME] || [os isEqualToString:@"any"])
					{
						osValid = YES;
					}
					
					osRecCount++;
					continue;
                }
                
                // UUID Restriction
                NSString *uuid = [UMUtil getMachineUUID];
                if ([uuid isEqualToString:licR.lockedToUUID])
                {
                    valid = YES;
                    NSLog(@"Valid UUID: %@", uuid);
                    break;
                }
                
                // Serial
                NSString *serialNum = [UMUtil getMachineSerialNumber];
                if ([serialNum isEqualToString:licR.lockedToSerial])
                {
                    valid = YES;
                    NSLog(@"Valid Serial: %@", serialNum);
                    break;
                }

                // CPU ids
                NSArray *cpuSerials = [UMUtil getCPUSerialNumbers];
                for( NSString *x in cpuSerials)
                {
                    if ([x isEqualToString:licR.lockedToCpuId])
                    {
                        valid = YES;
                        NSLog(@"Valid CPU-id: %@", x);
                        break;
                    }
                }
                    
                // Mac Address
                NSArray *arr = [UMUtil getArrayOfMacAddresses];
                for(NSString *ai in arr)
                {
                    if ([ai isEqualToString:licR.lockedToMacAddress])
                    {
                        valid = YES;
                        NSLog(@"Valid mac-address: %@", ai);
                        break;
                    }
                }
                
                // IPs
                NSDictionary<NSString *,NSArray<NSDictionary<NSString *,NSString *> *> *> *interface_ips;
                interface_ips = [UMUtil getIpAddrs];
                NSArray *interface_names = [interface_ips allKeys];
                for(NSString *interface_name in interface_names)
                {
                    NSArray<NSDictionary<NSString *,NSString *> *> *ips_per_if = interface_ips[interface_name];
                    for(NSDictionary<NSString *,NSString *> *entry in ips_per_if)
                    {
                        NSString *ip = entry[@"address"];
                        if ([ip isEqualToString:licR.lockedToIp])
                        {
                            valid = YES;
                            NSLog(@"Valid IP: %@", ip);
                            break;
                        }
                    }
                    
                    if(valid)
                    {
                        break;
                    }
                }
            }
            if(osRecCount == 0)
            {
                osValid=YES;
            }
        }
    }
    
    [_lock unlock];
    
    if(osValid && valid)
    {
        if(_debug)
        {
            fprintf(stderr,"DEBUG: license restrictions considered valid\n");
        }
        return YES;
    }
    if(_debug)
    {
        fprintf(stderr,"DEBUG: license restriction considered invalid\n");
    }
    return NO;
}

- (UMLicenseProductFeature *)getProduct:(NSString *)product
                                feature:(NSString *)feature
{
    [_lock lock];

    UMLicenseProductFeature *pf = NULL;
    NSUInteger i;
    NSUInteger n = [_licenseFiles count];
    for(i=0;i<n;i++)
    {
        UMLicenseFile *licFile = _licenseFiles[i];
        UMSignedLicense *slic = licFile.signedLicense;
        
        if(slic.license == NULL)
        {
            continue;
        }
        UMLicense *lic = slic.license;
        if(lic)
        {
            UMLicenseProductFeature *pf2 = [lic getProduct:product feature:feature];
            if(pf2)
            {
                if(pf==NULL)
                {
                    pf=pf2;
                }
                else if(pf2.licenseExpiration > pf.licenseExpiration)
                {
                    pf = pf2;
                }
            }
        }
    }
    [_lock unlock];

    return pf;
}

- (NSString *)description
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [_lock lock];
    NSArray *lfs = [_licenseFiles copy];
    [_lock unlock];
    for(UMLicenseFile *lf in lfs)
    {
        NSString *filename = lf.fullPath;
        UMSignedLicense *sl = lf.signedLicense;
        UMLicense *lic = sl.license;
        NSString *ostr = [lic.objectValue jsonString];
        [s appendFormat:@"LicenseFile: %@\n%@",filename,ostr];
    }
    return s;
}


- (NSString *)jsonString
{
    [_lock lock];
    NSArray *lfs = [_licenseFiles copy];
    [_lock unlock];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for(UMLicenseFile *lf in lfs)
    {
        UMSignedLicense *sl = lf.signedLicense;
        UMLicense *lic = sl.license;
        id o = [lic objectValue];
        [arr addObject:o];
    }

    UMJsonWriter *writer = [[UMJsonWriter alloc]init];
    writer.humanReadable = YES;
    NSString *string =  [writer stringWithObject:arr];
    return string;
}

- (void)refreshLicenses
{
    NSMutableDictionary *toUpdateAddress = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *toUpdateUrl = [[NSMutableDictionary alloc]init];
    NSDate *now = [NSDate date];

    /* first we update all via URL. if URL fails only then we will attempt update via Address */
    [_lock lock];
    for(UMLicenseFile *lf in _licenseFiles)
    {
        UMLicense *lic = lf.signedLicense.license;
        NSString  *serial = lf.signedLicense.license.licenseSerialNumber;
        if([lic.licenseType isEqualToString:@"renewing"])
        {
            if(lf.nextUpdate < now)
            {
                if(lic.licenseRenewUrl)
                {
                    toUpdateUrl[serial]=lic.licenseRenewUrl;
                }
            }
        }
    }
    [_lock unlock];
    
    NSArray *serials = [toUpdateUrl allKeys];
    for (NSString *serial in serials)
    {
        NSString *url = toUpdateUrl[serial];
        [self updateViaUrl:url serial:serial];
    }

    if(_updateByAddressDelegate)
    {
        
        /* if URL update is successful, then the update time will be updated so for the same it would fall through here */
        [_lock lock];
        for(UMLicenseFile *lf in _licenseFiles)
        {
            UMLicense *lic = lf.signedLicense.license;
            NSString  *serial = lf.signedLicense.license.licenseSerialNumber;
            if([lic.licenseType isEqualToString:@"renewing"])
            {
                if(lf.nextUpdate < now)
                {
                    if(lic.licenseRenewAddress)
                    {
                        toUpdateAddress[serial]=lic.licenseRenewAddress;
                    }
                }
            }
        }
        [_lock unlock];
        
        serials = [toUpdateAddress allKeys];
        for (NSString *serial in serials)
        {
            NSString *address = toUpdateAddress[serial];
            [_updateByAddressDelegate licenseUpdateRequestForAddress:address serial:serial];
        }
    }
}

- (void)appendProductParameters:(NSMutableString *)s
{
    if(_productHttpParameters == NULL)
    {
        return ;
    }
    NSArray *keys = [_productHttpParameters allKeys];
    for(NSString *key in keys)
    {
        id value = _productHttpParameters[key];
        if([value isKindOfClass:[NSString class]])
        {
            NSString *str = (NSString *)value;
            [s appendFormat:@"&%@=%@",key,[str urlencode]];
        }
        else if([value isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData *)value;
            [s appendFormat:@"&%@=%@",key,[data urlencode]];
        }
        else if([value isKindOfClass:[NSNumber class]])
        {
            NSNumber *num = (NSNumber *)value;
            NSString *str = [num stringValue];
            [s appendFormat:@"&%@=%@",key,[str urlencode]];
        }
    }
}

- (void)updateViaUrl:(NSString *)url
              serial:(NSString *)serial
{
    NSMutableString *full_url = [[NSMutableString alloc]init];
    [full_url appendFormat:@"%@?serial=%@",url,[serial urlencode]];
    [self appendProductParameters:full_url];

    NSURL *u = [[NSURL alloc]initWithString:full_url];
    NSError *e= NULL;

#ifdef __APPLE__
    NSData *data = [NSData dataWithContentsOfURL:u
                                         options:NSDataReadingUncached
                                           error:&e];
#else
    NSData *data = [NSData dataWithContentsOfURL:u];
#endif

    if((e==0) && (data.length > 0))
    {
        [self refreshLicenseSerial:serial data:data];
    }

}

- (void)refreshLicenseSerial:(NSString *)serial1  data:(NSData *)data
{
    [_lock lock];
    for(UMLicenseFile *lf in _licenseFiles)
    {
        NSString  *serial = lf.signedLicense.license.licenseSerialNumber;
        if([serial isEqualToString:serial1])
        {
            UMSignedLicense *slic_old = lf.signedLicense;
            [lf updateData:data];
            UMSignedLicense *slic = lf.signedLicense;
            if((slic.license == NULL) && ( slic.encryptedLicense !=NULL))
            {
                @try
                {
                    [slic decryptLicenseWithKeys:[_licenseDecryptionKeys copy]];
                }
                @catch(NSException *e)
                {
                            
                }
            }
            if(slic.license == NULL)
            {
                NSLog(@"Can not decrypt update license for %@. Reverting",lf.fullPath);
                lf.signedLicense = slic_old;
            }
            else
            {
                lf.signedLicense = slic;
                lf.lastRefresh = [NSDate date];
                [lf updateTimeIntervals];
            }
            break;
        }
    }
    [_lock unlock];
}

@end
