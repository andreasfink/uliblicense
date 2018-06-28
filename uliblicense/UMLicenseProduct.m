//
//  UMLicenseProduct.m
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import "UMLicenseProduct.h"
#import "UMLicenseProductFeature.h"
#import "UMLicenseProductFeatureList.h"
@implementation UMLicenseProduct

- (UMLicenseProduct *)init
{
    self = [super init];
    if(self)
    {
        _lock = [[UMMutex alloc]init];
    }
    return self;
}


- (UMLicenseProduct *)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        _lock = [[UMMutex alloc]init];
        _productName = name;
    }
    return self;
}

- (void)addFeature:(UMLicenseProductFeature *)feature
{
    if(_productFeatures==NULL)
    {
        _productFeatures = [[UMLicenseProductFeatureList alloc]init];
    }
    [_productFeatures addFeature:feature];
}


- (void)addFeatureWithName:(NSString *)featureName
{
    if(_productFeatures==NULL)
    {
        _productFeatures = [[UMLicenseProductFeatureList alloc]init];
    }
    [_productFeatures addFeatureWithName:featureName];
}

- (void)removeFeature:(NSString *)featureName
{
    [_productFeatures removeFeature:featureName];
}

- (UMLicenseProductFeature *)getFeature:(NSString *)name
{
    return [_productFeatures getFeature:name];
}


- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];

    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    if(_productName)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_productName];
        [utf8 processBeforeEncode];
        utf8.asn1_tag.tagNumber = 0;
        utf8.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:utf8];
    }
    else
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ENCODING_ERROR"
                                       reason:@"UMLicenseProduct productName missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(_productFeatures)
    {
        [_productFeatures processBeforeEncode];
        _productFeatures.asn1_tag.tagNumber = 1;
        _productFeatures.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [asn1_list addObject:_productFeatures];
    }
}

- (UMLicenseProduct *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    if((o) && (o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
        _productName = utf8.value;
        o = [self getObjectAtPosition:p++];
    }
    if((o) && (o.asn1_tag.tagNumber == 1) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
    {
        _productFeatures = [[UMLicenseProductFeatureList alloc]initWithASN1Object:o context:context];
        //o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicenseProduct";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    if(_productName)
    {
        dict[@"productName"] = _productName;
    }
    if(_productFeatures)
    {
        dict[@"productFeatures"] = _productFeatures.objectValue;
    }

    return dict;
}

@end
