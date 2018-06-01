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

- (void)addFeature:(UMLicenseProductFeature *)feature
{
    if(_featureList==NULL)
    {
        _featureList = [[UMLicenseProductFeatureList alloc]init];
    }
    [_featureList addFeature:feature];
}

- (void)removeFeature:(NSString *)featureName
{
    [_featureList removeFeature:featureName];
}

- (UMLicenseProductFeature *)getFeature:(NSString *)name
{
    return [_featureList getFeature:name];
}

@end
