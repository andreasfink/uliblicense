//
//  UMSignedLicense.m
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import "UMSignedLicense.h"
#import "UMLicense.h"

static const  char *(publicLicenseKeys[]) =
{
    "-----BEGIN RSA PUBLIC KEY-----"
    "MIICCgKCAgEAtgfe3y8+gy0jYj+2o4NMPbf3f03/lbnOsSvugDR2t5OqlBoyVJX4"
    "mIP3sEz9sCJG8KPKweg0f6ldXW+nxmnEB/KA61uRFmdvR0FJvak0AdMqYoLj91SN"
    "hunhngZcOr4E6RNwVB2oIEhNupL1n0/rwGhzwGqw550HFpAcoFP7nyu76UcQWCSH"
    "8/LA1/UTCZV+7pRiCxzajj1FyfAoWOkUyzMhVPlFOZ7Q9jevQ1U38AUJAqXSSHJa"
    "6NjOlEPtdr6YtQNfiYHWwNXfeJhMznSyi9yGqCTwTge3fr4VwYkjT2w0bONjk9SN"
    "AYVdCsd0CULmSq8Md5ow6xyi+xStyB5szGJg4r1w2eCL2wbExIMtSMfnG6xSFPtS"
    "7hP1xEUKjFZR0DnOsYGAQzSSC14Iw1M9F7/RrJS8a9zrLoh0jTfrYBW4c1ZzTd+h"
    "pvtG5TVS004/9gMHXs+jdBjUH5Kd2GiYgOJPFTYHAkyYEVVibtxyl2S4jV9UDaT+"
    "dNPB5+cspbsfw5bsURCxEg9Fm1/8d0Iq2EJkqC4Mi1+WCc8zQ3iWWOySrOa0E/Ri"
    "ES7lZYStGzm70usUAoFiAjOEpRn7DUCnlgA0eh1A+ymr22lor9nhrOr30PqU7igv"
    "d/Dc9DPzFZr/hGVTb7yPeFzSjfrp2+Wrqe1+GekMo5HsAHQTAh4AI1MCAwEAAQ=="
    "-----END RSA PUBLIC KEY-----",

    "-----BEGIN RSA PUBLIC KEY-----"
    "MIICCgKCAgEAsnwYMxqoVruJDzQWf8y8p1cx+Ocj8ga+yTzF7iQP7/GlQPSqxuF1"
    "RSYa4amZCEL5i+hmkSZjh0vQ6Zx00+iFVBK1Gj8Bzv09qs0keYYEkaJu8EFQlYAI"
    "c8ssFpFbP6mtBAl+IfZ89Dfsb6jYXzdWXb9ksCzYqYmVTGnbVqlqWPXw6W8wns2G"
    "qtl3mSVgDjLl2H9MXmMFeOoPmfOJHbJAbkIHfQ741tyuSl7kfOR/oca53NS1DT7d"
    "SJH00USLgQNHfgc7ply0+kRaBP1cQ06Hd7OmfEkkpwE9n89QRQYMNgewy9eZMcX4"
    "zxMA/xYWm7E/nxXWK4a5ZHyKBrSbjtFduS7LSYs+CuMjNjVu4K7Ohqrh1mYEN/Fd"
    "PbxTcVZ6ltyDxXGRN9aEpYk3hdRTclUFYwN1XSkvgkPTt/zdGXWEPU3ltqXPWV5U"
    "pOU5oRqk26j2/Am3sQTCCJzaleDMSvsE/CttGUSWiRIDDuEy/AGpswBfMVr+bhcz"
    "oW35GlC6YybYsFkMsj/hRoYDuylEPcn7dMR7jTys9w5ySx9TM9uVA53tmZSGAEB2"
    "AGqRgBRHfOXacYPcTrzsKXhWHg0TNiF9dpu53WTPthSzbqkIasmllK4FcHNpfIuC"
    "F5Y4pDhrnj863wq6kvh63crNIAjsWYDSnVd5kcoLjiJcKDtbrWrigUMCAwEAAQ=="
    "-----END RSA PUBLIC KEY-----",

};

@implementation UMSignedLicense

- (void)signWithPrivateKey:(NSData *)key
{
    _licenseData = [_license berEncoded];
    /*
    _encryptedLicenseData = 
    _hash = [licenseDate sha256];
    _signature = [licenseDate sha256];
*/
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    if(_license)
    {

        /*
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseSerialNumber];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 0;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];*/
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"USignedMLicense license missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
}


- (UMSignedLicense *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
#if 0
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseSerialNumber = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 1) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseType = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseOwner = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _licenseRestrictions = [[UMLicenseRestrictionList alloc]initWithASN1Object:o context:context];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseExpiration = [utf8.value dateValue];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseRenewUrl = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    while(o)
    {
        /* ... */
        o = [self getObjectAtPosition:p++];
    }
#endif
    return self;
}

- (NSString *) objectName
{
    return @"UMSignedLicense";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
#if 0
    if(_licenseSerialNumber)
    {
        dict[@"licenseSerialNumber"] = _licenseSerialNumber;
    }
    if(_licenseType)
    {
        dict[@"licenseType"] = _licenseType;
    }
    if(_licenseOwner)
    {
        dict[@"licenseOwner"] = _licenseOwner;
    }
    if(_licenseRestrictions)
    {
        dict[@"licenseRestrictions"] = _licenseRestrictions.objectValue;
    }
    if(_licenseExpiration)
    {
        dict[@"licenseExpiration"] = [NSString stringWithStandardDate:_licenseExpiration];
    }
    if(_licenseRenewUrl)
    {
        dict[@"licenseRenewUrl"] = _licenseRenewUrl;
    }
#endif
    return dict;
}

@end

