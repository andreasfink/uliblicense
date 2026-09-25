//
//  UMLicenseProductFeatureList.h
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulib/ulib.h>
@class UMLicenseProductFeature;

@interface UMLicenseProductFeatureList : UMASN1Sequence
{
    UMSynchronizedSortedDictionary *_featuresDict;
}

- (void)addFeature:(UMLicenseProductFeature *)feature;
- (void)addFeatureWithName:(NSString *)featureName;
- (void)removeFeature:(NSString *)featureName;
- (UMLicenseProductFeature *)getFeature:(NSString *)name;
- (void)setSpeedLimit:(double)speedLimit;
- (double)speedLimit;

@end
