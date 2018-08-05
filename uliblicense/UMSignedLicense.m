//
//  UMSignedLicense.m
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import "UMSignedLicense.h"
#import "UMLicense.h"
#import "UMLicenseRestrictionList.h"
#import "UMLicenseRestriction.h"
#import "UMLicenseProduct.h"
#import "UMEncryptedLicense.h"


@implementation UMSignedLicense

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    
    asn1_tag.tagNumber = 0;
    asn1_tag.tagClass = UMASN1Class_Application;

    if((_license == NULL) && (_encryptedLicense==NULL))
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense either license or encrypted license must be present"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    if(_license)
    {
        [_license processBeforeEncode];
        _license.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        _license.asn1_tag.tagNumber = 0;
        [asn1_list addObject:_license];
    }
    if(_encryptedLicense)
    {
        [_encryptedLicense processBeforeEncode];
        _encryptedLicense.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        _encryptedLicense.asn1_tag.tagNumber = 1;
        [asn1_list addObject:_encryptedLicense];
    }
    if(_hashData)
    {
        UMASN1OctetString *o = [[UMASN1OctetString alloc]initWithValue:_hashData];
        [o processBeforeEncode];
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        o.asn1_tag.tagNumber =2;
        [asn1_list addObject:o];
    }
    if(_signature)
    {
        UMASN1OctetString *o = [[UMASN1OctetString alloc]initWithValue:_signature];
        [o processBeforeEncode];
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        o.asn1_tag.tagNumber =3;
        [asn1_list addObject:o];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense signature missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    UMASN1Integer *v = [[UMASN1Integer alloc]init];
    v.value = _variant;
    [v processBeforeEncode];
    v.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    v.asn1_tag.tagNumber = 4;
    [asn1_list addObject:v];

    if(_plaintext)
    {
        UMASN1UTF8String *o = [[UMASN1UTF8String alloc]initWithValue:_plaintext];
        [o processBeforeEncode];
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        o.asn1_tag.tagNumber = 5;
        [asn1_list addObject:o];
    }
}

- (void)decryptLicenseWithKeys:(NSArray *)keys
{
    if((_encryptedLicense == NULL) && (_variant != UMLicense_EncryptionVariant_none))
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense no encrypted data present to decrypt"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    if (_variant == UMLicense_EncryptionVariant_rsa)
    {
        NSUInteger keysCount = keys.count;
        for(int keyIndex=0;keyIndex < keysCount;keyIndex++)
        {
            NSString *privateKey = keys[keyIndex];
            if([self decryptLicenseWithRSAPrivateKey:privateKey]==YES)
            {
                break;
            }
        }
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:[NSString stringWithFormat:@"UMSignedLicense unknown variant (%d)",_variant]
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
}

- (void)encryptLicenseWithRSAPublicKey:(NSString *)publicKey
{
    if(_license == NULL)
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense no license data present to encrypt"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    _encryptedLicense = [[UMEncryptedLicense alloc]initWithUnencryptedLicense:_license
                                                                    publicKey:publicKey];
    if(_encryptedLicense)
    {
        _license = NULL;
        _variant = UMLicense_EncryptionVariant_rsa;
    }
}

- (BOOL)decryptLicenseWithRSAPrivateKey:(NSString *)privateKey /* returns YES on success */
{
    if(_encryptedLicense == NULL)
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense no license data present to decryot"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    NSData *data = [_encryptedLicense decryptedDataForPrivateKey:privateKey];
    if([[data sha256] isEqualToData: _hashData])
    {
        NSUInteger i=0;
        _license = [[UMLicense alloc]initWithBerData:data atPosition:&i context:NULL];
        if(_license)
        {
            _encryptedLicense = NULL;
            _variant = UMLicense_EncryptionVariant_none;
            return YES;
        }
    }
    
    return NO;
}

- (void)signLicenseWithRSAPublicKey:(NSString *)publicKey
{
    NSData *data = [_license berEncoded];
    _hashData = [data sha256];
    
    UMCrypto *crypto = [[UMCrypto alloc]init];
    crypto.publicKey = publicKey;
    _signature = [crypto RSAEncryptWithPlaintextSSLPublic:_hashData];
}

- (BOOL)isSignatureValidForKeys:(NSArray *)keys; /* verifies _hashData against _signature */
{
    for(NSString *key in keys)
    {
        if( [self isSignatureValidForRSAPrivateKey:key])
        {
            _isValid=YES;
            return YES;
        }
    }
    return NO;
}

-(BOOL)isSignatureValidForRSAPrivateKey:(NSString *)privateKey
{
    UMCrypto *crypto = [[UMCrypto alloc]init];
    crypto.privateKey = privateKey;

    NSData *signatureHash = [crypto RSADecryptWithCiphertextSSLPrivate:_signature];
    if([signatureHash isEqualToData:_hashData])
    {
        return YES;
    }
    return NO;
}

- (UMSignedLicense *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];

    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _license = [[UMLicense alloc]initWithASN1Object:o context:context];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 1) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _encryptedLicense = [[UMEncryptedLicense alloc]initWithASN1Object:o context:context];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 2) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _hashData = oct.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 3) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _signature = oct.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 4) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1Integer *v = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
        _variant = (UMLicense_EncryptionVariant)v.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 5) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _plaintext = utf8.value;
        o = [self getObjectAtPosition:p++];
    }

    while(o)
    {
        /* ... */
        o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMSignedLicense";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    if(_license)
    {
        dict[@"license"] = _license.objectValue;
    }
    if(_encryptedLicense)
    {
        dict[@"encryptedLicense"] = _encryptedLicense;
    }
    if(_hashData)
    {
        dict[@"hashData"] = _hashData;
    }
    if(_signature)
    {
        dict[@"signature"] = _signature;
    }
    dict[@"variant"] = @(_variant);
    if(_plaintext)
    {
        dict[@"plaintext"] = _plaintext;
    }
    return dict;
}


@end

