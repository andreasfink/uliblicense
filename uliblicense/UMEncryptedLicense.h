//
//  UMEncryptedLicense.h
//  uliblicense
//
//  Created by Andreas Fink on 01.06.18.
//

#import <ulibasn1/ulibasn1.h>
@class UMLicense;

@interface UMEncryptedLicense : UMASN1Sequence
{
    NSString *_encryptionMethod;
    NSData  *_encryptedStreamKey;
    NSData *_encryptedData;
}

@property(readwrite,strong) NSString *encryptionMethod;
@property(readwrite,strong) NSData   *encryptedStreamKey;
@property(readwrite,strong) NSData   *encryptedData;

- (UMEncryptedLicense *)initWithUnencryptedLicense:(UMLicense *)lic
                                         publicKey:(NSString *)key;

- (NSData *)decryptedDataForPrivateKey:(NSString *)key;

@end
