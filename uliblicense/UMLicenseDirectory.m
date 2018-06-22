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

@implementation UMLicenseDirectory

- (void)genericInitialisation
{
    _licenseFiles = [[NSMutableArray alloc] init];
    _licenseDecryptionKeys = [[NSMutableArray alloc] init];
    _licenseSignatureKeys = [[NSMutableArray alloc] init];
    _lock = [[UMMutex alloc]init];
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
    [_lock lock];
    NSFileManager *mgr = [NSFileManager defaultManager];
    for (NSString *filePath in [mgr enumeratorAtPath:path])
    {
        NSError *err = nil;
        NSString *fullPath = [path stringByAppendingPathComponent:filePath];
        NSDictionary *itemInfo = [mgr attributesOfItemAtPath:fullPath error:&err];
        if (itemInfo)
        {
            if ([itemInfo objectForKey:NSFileType] == NSFileTypeRegular)
            {
                if([fullPath hasSuffix:@".license"])
                {
                    UMLicenseFile *licenseFile = [[UMLicenseFile alloc]initWithFilename:fullPath];
                    if(licenseFile)
                    {
                        [self addLicenseFile:licenseFile];
                    }
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
            n++;
        }
        
        if((slic.license == NULL) && ( slic.encryptedLicense !=NULL))
        {
            [slic decryptLicenseWithKeys:[_licenseDecryptionKeys copy]];
        }
        if(slic.license == NULL)
        {
            [_licenseFiles removeObjectAtIndex:i];
            n++;
        }
    }
    [_lock unlock];

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
