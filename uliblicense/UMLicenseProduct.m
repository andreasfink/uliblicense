//
//  UMLicenseProduct.m
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import "UMLicenseProduct.h"
#import "UMLicenseProductFeature.h"

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

- (void)addFeature:(UMLicenseProductFeature *)feature
{
    if(feature.featureName.length > 0)
    {
        [_lock lock];
        _features[feature.featureName] = feature;
        [_lock unlock];
    }
}

- (void)removeFeature:(NSString *)feature
{
    if(feature.length >0 )
    {
        [_lock lock];
        [_features removeObjectForKey:feature];
        [_lock unlock];
    }
}

- (UMLicenseProductFeature *)getFeature:(NSString *)name
{
    UMLicenseProductFeature *feature;
    if(name.length > 0)
    {
        [_lock lock];
        feature = _features[feature.featureName];
        [_lock unlock];
    }
    return feature;
}

@end
