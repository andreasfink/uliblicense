//
//  UMSignedLicense.h
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulibasn1/ulibasn1.h>
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
    BOOL                isValid;
    int                 _keyLength;
}

@property(readwrite,strong) UMLicense           *license;
@property(readwrite,strong) UMEncryptedLicense  *encryptedLicense;
@property(readwrite,strong) NSData          *hashData;
@property(readwrite,strong) NSData          *signature;
@property(readwrite,assign) UMLicense_EncryptionVariant variant;
@property(readwrite,strong) NSString        *plaintext;
@property(readwrite,assign) int             keyLength;

- (void)decryptLicense;
- (void)encryptLicenseWithRSAPrivateKey:(NSString *)privateKey;
- (BOOL)decryptLicenseWithRSAPublicKey:(NSString *)publicKey; /* returns YES on success */
- (void)signLicenseWithRSAPrivateKey:(NSString *)privateKey;
- (BOOL)isSignatureValid;

+ (void)cryptoTest;

@end

