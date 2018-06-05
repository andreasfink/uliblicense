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

- (void)scanDirectoryForLicenseFiles:(NSString *)path
{
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


- (void)addKey:(NSString *)key
{
    if(key)
    {
        [_lock lock];
        [_licenseDecryptionKeys addObject:key];
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
            NSLog(@"Can not decrypt licensefile %@",licFile.filename);
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
            NSLog(@"Invalid signature in %@",licFile.filename);
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
        NSString *filename = lf.filename;
        UMSignedLicense *sl = lf.signedLicense;
        UMLicense *lic = sl.license;
        NSString *ostr = [lic.objectValue jsonString];
        [s appendFormat:@"LicenseFile: %@\n%@",filename,ostr];
    }
    return s;
}


- (void)refreshLicenses
{
    NSMutableDictionary *toUpdate = [[NSMutableDictionary alloc]init];
    [_lock lock];
    for(UMLicenseFile *lf in _licenseFiles)
    {
        NSString *filename = lf.filename;
        UMLicense *lic = lf.signedLicense.license;
        if([lic.licenseType isEqualToString:@"renewing"])
        {
            if(lic.licenseRenewUrl)
            {
                toUpdate[@"filename"]=lic.licenseRenewUrl;
            }
        }
    }
    [_lock unlock];
}

@end
