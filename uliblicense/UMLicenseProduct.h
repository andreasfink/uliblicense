//
//  UMLicenseProduct.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>

@class UMLicenseProductFeatureList;
@class UMLicenseProductFeature;

@interface UMLicenseProduct : UMASN1Sequence
{
    NSString    *_productName;
    UMMutex *_lock;
    UMLicenseProductFeatureList *_featureList;
}

@property(readwrite,strong) NSString    *productName;

- (void)addFeature:(UMLicenseProductFeature *)feature;
- (void)removeFeature:(NSString *)feature;
- (UMLicenseProductFeature *)getFeature:(NSString *)name;

@end
