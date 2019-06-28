//
//  UMLicenseDirectory.h
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
// 

#import <ulib/ulib.h>
#import "UMLicenseRefreshDelegateProtocol.h"
@class UMLicenseProductFeature;
@class UMLicense;
@class UMLicenseFile;

@interface UMLicenseDirectory : UMObject
{
    NSMutableArray *_licenseFiles;
    NSMutableArray *_licenseDecryptionKeys;
    NSMutableArray *_licenseSignatureKeys;
    UMMutex          *_lock;
    NSString    *_licenseDirectory;
    UMTimer *_timer;
    id<UMLicenseRefreshDelegateProtocol> _updateByAddressDelegate;
    id<UMLicenseRefreshDelegateProtocol> _reportByAddressDelegate;
    NSDictionary *_productHttpParameters;
    BOOL _debug;
}

@property(readwrite,strong)    id<UMLicenseRefreshDelegateProtocol> updateByAddressDelegate;
@property(readwrite,strong)     NSDictionary *productHttpParameters;
@property(readwrite,assign)  BOOL debug;

- (NSArray *)licenseDecryptionKeys;
- (NSArray *)licenseSignatureKeys;

- (void)scanDirectoryForLicenseFiles:(NSString *)path;
- (void)addLicenseFile:(UMLicenseFile *)licenseFile;
- (void)addDecryptionKey:(NSString *)key;
- (void)addSignatureVerificationKey:(NSString *)key;
- (void)decryptLicenses;
- (void)validateSignatures;
- (UMLicenseProductFeature *)getProduct:(NSString *)product feature:(NSString *)feature;
- (void)refreshLicenses;
- (void)startAutoRefresh;
- (void)stopAutoRefresh;
- (BOOL)validateRestrictions;
- (NSString *)jsonString;

@end

