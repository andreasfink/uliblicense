//
//  UMLicenseDirectory.h
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import <ulib/ulib.h>
@class UMLicenseProductFeature;
@class UMLicense;
@class UMLicenseFile;

@interface UMLicenseDirectory : UMObject
{
    NSMutableArray *_licenseFiles;
    NSMutableArray *_licenseDecryptionKeys;
    NSMutableArray *_licenseSignatureKeys;
    UMMutex          *_lock;
}

- (void)scanDirectoryForLicenseFiles:(NSString *)path;
- (void)addLicenseFile:(UMLicenseFile *)licenseFile;
- (void)addKey:(NSString *)key;
- (void)decryptLicenses;
- (void)validateSignatures;
- (UMLicenseProductFeature *)getProduct:(NSString *)product feature:(NSString *)feature;
- (void)refreshLicenses;

@end

