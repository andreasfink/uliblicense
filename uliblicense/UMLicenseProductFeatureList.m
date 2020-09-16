//
//  UMLicenseProductFeatureList.m
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import "UMLicenseProductFeatureList.h"
#import "UMLicenseProductFeature.h"

@implementation UMLicenseProductFeatureList

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    _asn1_tag.isConstructed=YES;
    _asn1_list = [[NSMutableArray alloc]init];
    if(_featuresDict)
    {
        NSArray *_featuresDictKey = [_featuresDict allKeys];
        for(id key in _featuresDictKey)
        {
            UMLicenseProductFeature *f = _featuresDict[key];
            f.asn1_tag.tagNumber = 0;
            f.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
            [_asn1_list addObject:f];
        }
    }
}

- (UMLicenseProductFeatureList *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    _featuresDict = [[UMSynchronizedSortedDictionary alloc]init];
    while(o)
    {
        if((o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
        {
            UMLicenseProductFeature *feature = [[UMLicenseProductFeature alloc]initWithASN1Object:o context:context];
            if(feature.featureName)
            {
                _featuresDict[feature.featureName] = feature;
            }
        }
        o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (void)addFeature:(UMLicenseProductFeature *)feature
{
    if(feature.featureName)
    {
        if(_featuresDict==NULL)
        {
            _featuresDict = [[UMSynchronizedSortedDictionary alloc]init];
        }
        _featuresDict[feature.featureName] = feature;
    }
}


- (void)addFeatureWithName:(NSString *)featureName
{
    if(featureName)
    {
        if(_featuresDict==NULL)
        {
            _featuresDict = [[UMSynchronizedSortedDictionary alloc]init];
        }
        _featuresDict[featureName] = [[UMLicenseProductFeature alloc]initWithName:featureName];
    }
}

- (void)removeFeature:(NSString *)featureName
{
    [_featuresDict removeObjectForKey:featureName];
}

- (UMLicenseProductFeature *)getFeature:(NSString *)name
{
    return _featuresDict[name];
}


- (NSString *) objectName
{
    return @"UMLicenseProductFeatureList";
}

- (id) objectValue
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSArray *keys = [_featuresDict allKeys];
    for(NSString *key in keys)
    {
        UMLicenseProductFeature *f = _featuresDict [key];
        if(f)
        {
            [arr addObject:f.objectValue];
        }
    }
    return arr;
}


@end
