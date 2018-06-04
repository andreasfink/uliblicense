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

static const  char *(privateLicenseDecryptionKeys[]) =
{
    "xx",

    "yyy",
};

#define PUBLIC_KEYS_COUNT   2

const unsigned char key128[128] = {0x11,0xe7,0x5c,0xf8,0x55,0xc2,0xf1,0xb1,0xe5,0xe5,0x51,0x4c,0x94,0x5e,0xb8,0x77,0x36,0xe6,0x81,0xf8,0x1d,0x2f,0x04,0x88,0xd6,0x21,0x92,0x4b,0x58,0x54,0x04,0x69,0x3b,0x61,0x62,0x90,0x23,0x53,0x42,0x09,0x38,0x93,0x55,0xcc,0xf2,0x0d,0x43,0x28,0xf4,0xc4,0x20,0x11,0xf3,0x25,0x9a,0xca,0x46,0x2c,0x15,0x9e,0x81,0x1a,0x08,0xbc,0x7b,0x6a,0x4d,0x9e,0xbd,0x8f,0xa7,0xf5,0x22,0xfd,0xc1,0x14,0x0a,0x05,0x3c,0xfe,0xc9,0x5d,0x10,0xbd,0x82,0xaa,0x87,0xc8,0xd6,0x9c,0x66,0x57,0xb6,0x6e,0x14,0x31,0xd8,0x61,0xd0,0x95,0xf0,0x77,0x8a,0x12,0x74,0x4c,0x27,0x7f,0x51,0x63,0x7d,0x1a,0xc0,0x8d,0xd7,0x42,0x37,0x5e,0x0a,0x0e,0xfb,0x71,0x65,0xb1,0xdf,0x79,0xe3,0xb8};

static NSData *simpleEncryptData(NSData *data, NSData *keyData)
{

    size_t output_size = (([data length]*4+1023) / 1024) * 1024;
    unsigned char *output_ptr =  (unsigned char *)malloc(output_size);

    size_t input_size = (([data length]+1023) / 1024) * 1024;
    unsigned char *input_ptr =  (unsigned char *)malloc(input_size);

    size_t key_size = [keyData length];
    const unsigned char *key =  (const unsigned char *)[keyData bytes];

    memset(input_ptr,0x00,input_size);
    memcpy(input_ptr,[data bytes],[data length]);

    /* we pad to the next 1k with zero's */
    size_t new_output_size = 0;

    int j = 0;
    for(int i=0;i<input_size;i++)
    {
        output_ptr[i] = input_ptr[i] ^ key[j];
        j = j+1;
        j = j % key_size;
        new_output_size++;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    return result;
}

static NSData *simpleDecryptData(NSData *data, NSData *keyData)
{
    return simpleEncryptData(data,keyData);
}


@implementation UMSignedLicense

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
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
                                       reason:@"UMSignedLicense variant missing"
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

    UMASN1Integer *kl = [[UMASN1Integer alloc]init];
    kl.value = _keyLength;
    [kl processBeforeEncode];
    kl.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    kl.asn1_tag.tagNumber = 6;
    [asn1_list addObject:kl];
}

- (void)decryptLicense
{
    if((_encryptedLicense == NULL) && (_variant != UMLicense_EncryptionVariant_none))
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense no encrypted data present to decrypt"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    if (_variant == UMLicense_EncryptionVariant_rsa)
    {
        BOOL hasValidHash = NO;
        for(int keyIndex=0;keyIndex < PUBLIC_KEYS_COUNT;keyIndex++)
        {
            NSString *privateKey = @(privateLicenseDecryptionKeys[keyIndex]);
            if([self decryptLicenseWithRSAPrivateKey:privateKey]==YES)
            {
                break;
            }
        }
        if(!hasValidHash)
        {
            @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                           reason:@"UMSignedLicense could not decrypt license"
                                         userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
        }
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense unknown variant"
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

    UMCrypto *crypto = [[UMCrypto alloc]init];
    crypto.publicKey = publicKey;

    NSData *des6 = [UMCrypto randomDataOfLength:DES3_KEY_LEN*2];
    NSData *encryptedDes6Key = [crypto RSAEncryptWithPlaintextSSLPublic:des6];

    NSData *d = [_license berEncoded];

    _hashData = [d sha256];

    _encryptedLicense = [[UMEncryptedLicense alloc]initWithUnencryptedData:d];

    if(_encryptedLicense)
    {
        _license = NULL;
        _variant = UMLicense_EncryptionVariant_rsa;
        _keyLength =4096;
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

    UMCrypto *crypto = [[UMCrypto alloc]init];
    crypto.privateKey = [privateKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *d = [crypto RSADecryptWithCiphertextSSLPrivate:_encryptedLicense];
    if([[d sha256] isEqualToData: _hashData])
    {
        UMASN1OctetString *o =  [[UMASN1OctetString alloc]initWithValue:d];
        _license = [[UMLicense alloc]initWithASN1Object:o context:NULL];
        if(_license)
        {
            _encryptedLicense = NULL;
            _variant = UMLicense_EncryptionVariant_none;
            return YES;
        }
    }
    return NO;
}


- (void)signLicenseWithRSAPrivateKey:(NSString *)privateKey
{

    NSData *key = [privateKey dataUsingEncoding:NSUTF8StringEncoding];

    UMCrypto *crypto = [[UMCrypto alloc]init];
    crypto.privateKey = key;
    if(_license == NULL)
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMSignedLicense no license data present to sign"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }

    NSData *d = [_license berEncoded];
    _hashData = [d sha256];
    _signature = [crypto RSAEncryptWithPlaintextSSLPrivate:_hashData];
}

-(void)isSignatureValidForRSAPublicKey
{

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
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _encryptedLicense = oct.value;
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

    if((o) && (o.asn1_tag.tagNumber == 6) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1Integer *v = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
        _keyLength = (UMLicense_EncryptionVariant)v.value;
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
    dict[@"keyLength"] = @(_keyLength);
    return dict;
}


+(void)cryptoTest
{
    NSDictionary *d = [UMCrypto generateRsaKeyPair];
    NSString *privateKey = d[@"private-key"];
    NSString *publicKey = d[@"public-key"];

    fprintf(stdout,"Generating keypair successful\n");


    UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
    rest.lockedToIp = @"127.0.0.1";

    UMLicenseRestrictionList *restList = [[UMLicenseRestrictionList alloc]init];
    [restList addRestriction:rest];

    NSMutableDictionary *products = [[NSMutableDictionary alloc]init];

    UMLicenseProduct *product1 = [[UMLicenseProduct alloc]init];
    product1.productName = @"TestProduct1";
    products[product1.productName] = product1;

    UMLicenseProduct *product2 = [[UMLicenseProduct alloc]init];
    product2.productName = @"TestProduct2";
    products[product2.productName] = product2;

    UMLicense *lic = [[UMLicense alloc]init];
    lic.licenseSerialNumber = @"TEST";
    lic.licenseType = @"volatile";
    lic.licenseOwner = @"nobody";
    lic.licenseExpiration = [NSDate date];
    lic.licenseRenewUrl = @"https://127.0.0.1/verifyLicense.php";
    lic.licenseRestrictions = restList;
    lic.products = products;


    UMSignedLicense *slic = [[UMSignedLicense alloc]init];
    slic.license = lic;

    NSLog(@"SignedLicense: %@",[[slic objectValue] jsonString]);
    [slic encryptLicenseWithRSAPublicKey:publicKey];
    NSLog(@"SignedLicense encrypted: %@",[[slic objectValue] jsonString]);

    [slic decryptLicenseWithRSAPrivateKey:privateKey];

    NSLog(@"SignedLicense decrypted: %@",[[slic objectValue] jsonString]);
}

@end

