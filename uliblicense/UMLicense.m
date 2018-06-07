//
//  UMLicense.m
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import "UMLicense.h"
#import "UMLicenseRestriction.h"
#import "UMLicenseRestrictionList.h"
#import "UMLicenseProductList.h"
#import "UMLicenseProduct.h"
#import "UMLicenseProductFeature.h"


@implementation UMLicense

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    if(_licenseSerialNumber)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseSerialNumber];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 0;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicense licenseSerialNumber missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_licenseType)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseType];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 1;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicense licenseType missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_licenseOwner)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseOwner];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 2;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicense licenseOwner missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_licenseRestrictions)
    {
        [_licenseRestrictions processBeforeEncode];
        _licenseRestrictions.asn1_tag.tagNumber = 3;
        _licenseRestrictions.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:_licenseRestrictions];
    }
    if(_licenseProducts)
    {
        [_licenseProducts processBeforeEncode];
        _licenseProducts.asn1_tag.tagNumber = 4;
        _licenseProducts.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:_licenseProducts];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicense licensePorudct missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_licenseExpiration)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:[NSString stringWithStandardDate:_licenseExpiration]];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 5;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:PERPETUAL_LICENSE_DATE_STRING];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 5;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    if(_licenseRenewUrl)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseRenewUrl];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 6;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    if(_licenseRenewAddress)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseRenewUrl];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 7;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    if(_licenseRenewTimerMin)
    {
        UMASN1Integer *asn1int = [[UMASN1Integer alloc]initWithValue:[_licenseRenewTimerMin intValue]];
        [asn1int processBeforeEncode];
        asn1int.asn1_tag.tagNumber = 8;
        asn1int.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:asn1int];
    }
    if(_licenseRenewTimerMax)
    {
        UMASN1Integer *asn1int = [[UMASN1Integer alloc]initWithValue:[_licenseRenewTimerMax intValue]];
        [asn1int processBeforeEncode];
        asn1int.asn1_tag.tagNumber = 9;
        asn1int.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:asn1int];
    }
    if(_licenseEmail)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_licenseEmail];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 10;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicense licenseEmail missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
}


- (UMLicense *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
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
    if((o) && (o.asn1_tag.tagNumber == 2) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseOwner = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 3) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _licenseRestrictions = [[UMLicenseRestrictionList alloc]initWithASN1Object:o context:context];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 4) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _licenseProducts = [[UMLicenseProductList alloc]initWithASN1Object:o context:context];
        o = [self getObjectAtPosition:p++];
    }

    if((o) && (o.asn1_tag.tagNumber == 5) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseExpiration = [utf8.value dateValue];
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 6) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseRenewUrl = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 7) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseRenewAddress = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 8) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1Integer *asnint = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
        _licenseRenewTimerMin = @(asnint.value);
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 9) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1Integer *asnint = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
        _licenseRenewTimerMax = @(asnint.value);
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 10) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _licenseEmail = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
#if 0
    while(o)
    {
        /* ... */
        o = [self getObjectAtPosition:p++];
    }
#endif
    if(_licenseExpiration==NULL)
    {
        _licenseExpiration =[PERPETUAL_LICENSE_DATE_STRING dateValue];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicense";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
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
    if(_licenseProducts)
    {
        dict[@"licenseProducts"] = _licenseProducts.objectValue;
    }
    if(_licenseExpiration)
    {
        dict[@"licenseExpiration"] = [NSString stringWithStandardDate:_licenseExpiration];
    }
    if(_licenseRenewUrl)
    {
        dict[@"licenseRenewUrl"] = _licenseRenewUrl;
    }
    if(_licenseRenewAddress)
    {
        dict[@"licenseRenewAddress"] = _licenseRenewAddress;
    }
    return dict;
}

- (void)addProduct:(UMLicenseProduct *)product
{
    if(_licenseProducts==NULL)
    {
        _licenseProducts = [[UMLicenseProductList alloc]init];
    }
    [_licenseProducts addProduct:product];
}

- (void)removeProduct:(NSString *)productName
{
    [_licenseProducts removeProduct:productName];
}

- (UMLicenseProduct *)getProduct:(NSString *)name
{
    return [_licenseProducts getProduct:name];
}

- (void)addRestriction:(UMLicenseRestriction *)rest
{
    if(_licenseRestrictions==NULL)
    {
        _licenseRestrictions = [[UMLicenseRestrictionList alloc]init];
    }
    [_licenseRestrictions addRestriction:rest];
}

- (UMLicenseProductFeature *)getProduct:(NSString *)product feature:(NSString *)feature
{
    UMLicenseProduct *p = [self getProduct:product];
    if(p==NULL)
    {
        return NULL;
    }
    UMLicenseProductFeature *f = [p getFeature:feature];
    f = [f copy];
    f.licenseSerialNumber = _licenseSerialNumber;
    f.licenseExpiration = _licenseExpiration;
    return f;
}
@end

