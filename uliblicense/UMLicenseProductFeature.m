//
//  UMLicenseProductFeature.m
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import "UMLicenseProductFeature.h"

@implementation UMLicenseProductFeature

- (UMLicenseProductFeature *)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        _featureName = name;
    }
    return self;
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    _asn1_tag.isConstructed=YES;
    _asn1_list = [[NSMutableArray alloc]init];
    if(_featureName)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_featureName];
        utf8.asn1_tag.tagNumber = 0;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicenseProductFeature featureName missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_featureData)
    {
        UMASN1OctetString *o = [[UMASN1OctetString alloc]initWithValue:_featureData];
        o.asn1_tag.tagNumber = 0;
        o.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:o];
    }
}

- (UMLicenseProductFeature *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    if((o.asn1_tag.tagNumber==0) && (o.asn1_tag.tagClass==UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _featureName = utf8.value;
        o = [self getObjectAtPosition:p++];

    }
    if((o.asn1_tag.tagNumber==1) && (o.asn1_tag.tagClass==UMASN1Class_ContextSpecific))
    {
        UMASN1OctetString *oct = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];
        _featureData = oct.value;
        //o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicenseProductFeature";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    if(_featureName)
    {
        dict[@"featureName"] = _featureName;
    }
    if(_featureData)
    {
        dict[@"featureData"] = _featureData;
    }
    return dict;
}

- (UMLicenseProductFeature *)copyWithZone:(NSZone *)zone
{
    UMLicenseProductFeature *n = [[UMLicenseProductFeature allocWithZone:zone]initWithASN1Object:self context:NULL];
    n.featureName = _featureName;
    n.featureData = _featureData;
    n.licenseExpiration = _licenseExpiration;
    n.licenseSerialNumber = _licenseSerialNumber;
    return n;
}
@end
