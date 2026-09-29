//
//  UMSignedLicense.h
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulib/ulib.h>
@class UMLicense;
@class UMEncryptedLicense;

typedef enum UMLicense_EncryptionVariant
{
    UMLicense_EncryptionVariant_none   = 0,
    UMLicense_EncryptionVariant_simple = 1, /* not really secure. just obfuscating a bit */
    UMLicense_EncryptionVariant_rsa    = 2, /* more secure. to be implemented */
} UMLicense_EncryptionVariant;

@interface UMSignedLicense : UMASN1Sequence
{
    UMLicense           *_license;
    UMEncryptedLicense  *_encryptedLicense;
    NSData              *_hashData;
    NSData              *_signature;
    UMLicense_EncryptionVariant _variant;
    NSString            *_plaintext;
    BOOL                _isValid;
}

@property(readwrite,strong) UMLicense           *license;
@property(readwrite,strong) UMEncryptedLicense  *encryptedLicense;
@property(readwrite,strong) NSData              *hashData;
@property(readwrite,strong) NSData          *signature;
@property(readwrite,assign) UMLicense_EncryptionVariant variant;
@property(readwrite,strong) NSString        *plaintext;
@property(readwrite,assign) BOOL            isValid;

- (void)decryptLicenseWithKeys:(NSArray *)keys;
- (void)encryptLicenseWithRSAPublicKey:(NSString *)privateKey;
- (BOOL)decryptLicenseWithRSAPrivateKey:(NSString *)keys; /* returns YES on success */
- (void)signLicenseWithRSAPublicKey:(NSString *)publicKey;
- (BOOL)isSignatureValidForRSAPrivateKey:(NSString *)privateKey; /* verifies _hashData against _signature */

- (BOOL)isSignatureValidForKeys:(NSArray *)keys; /* verifies _hashData against _signature */

@end

