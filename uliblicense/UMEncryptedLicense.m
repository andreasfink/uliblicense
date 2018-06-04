//
//  UMEncryptedLicense.m
//  uliblicense
//
//  Created by Andreas Fink on 01.06.18.
//

#import "UMEncryptedLicense.h"

@implementation UMEncryptedLicense

/*
UMEncryptedLicense ::= SEQUENCE {
    encryptionMethod         [0] UTF8String,
    encryptedStreamKey   [1] OCTET STRING,
    encryptedData        [2] OCTET STRING,
}
*/

- (UMEncryptedLicense *)initWithUnencryptedData:(NSData *)d publicKey:(NSString *)key
{
    self [super init];
    if(self)
    {
        UMCrypto *crypto;
        crypto.publicKey = key;
        streamKey = [UMCrypto AES256RandomKey];
        streamIV =  [UMCrypto AES256RandomIV];
        _encryptedStreamKey = [crypto RSAEncryptWithPlaintextSSLPublic:streamKey];
        _encryptedData = [crypto AES256EncryptWithPlaintext:d key:streamKey iv:streamIV];
        _encryptionMethod = @"RSA-AES256";
    }
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];

    if(_encryptionMethod)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_cypherMethod];

        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        utf8.asn1_tag.tagNumber = 0;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMEncryptedLicense encryptionMethod must be present"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_encryptedStreamKey)
    {
        UMASN1OctetString *o = [[UMASN1OctetString alloc]initWithValue:_encryptedStreamKey];
        [o processBeforeEncode];
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        o.asn1_tag.tagNumber = 1;
        [asn1_list addObject:o];
    }
    if(_encryptedData)
    {
        UMASN1OctetString *o = [[UMASN1OctetString alloc]initWithValue:_encryptedData];
        [o processBeforeEncode];
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        o.asn1_tag.tagNumber =2;
        [asn1_list addObject:o];
    }
}

- (UMSignedLicense *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];

    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 =  [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _encryptionMethod = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 1) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _encryptedStreamKey = oct.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 2) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _encryptedData = oct.value;
        o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMEncryptedLicense";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    if(_encryptionMethod)
    {
        dict[@"_encryptionMethod"] = _encryptionMethod;
    }
    if(_encryptedStreamKey)
    {
        dict[@"encryptedStreamKey"] = _encryptedStreamKey.objectValue;
    }
    if(_encryptedData)
    {
        dict[@"_encryptedData"] = _encryptedData.objectValue;
    }
    return dict;
}

@end

