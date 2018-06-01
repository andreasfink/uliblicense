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
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    if(_featuresDict)
    {
        NSArray *_featuresDictKey = [_featuresDict allKeys];
        for(id key in _featuresDictKey)
        {
            [asn1_list addObject:_featuresDict[key]];
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
        UMLicenseProductFeature *feature = [[UMLicenseProductFeature alloc]initWithASN1Object:o context:context];
        if(feature.featureName)
        {
            _featuresDict[feature.featureName] = feature;
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
    return _featuresDict;
}


@end
