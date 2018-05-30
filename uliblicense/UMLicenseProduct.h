//
//  UMLicenseProduct.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
@class UMLicenseProductFeature;

@interface UMLicenseProduct : UMObject
{
    UMMutex *_lock;
    BOOL    _productIsPermanentlyAvailable;
    BOOL    _productIsTemporaryAvailable;
    NSString *_productRenewUrl;
    NSDate  *_productStartDate;
    NSDate  *__productEndDateDate;
    NSNumber    *_productMaxUseCount;
    NSNumber    *_productMaxDurationSinceStart;
    NSMutableDictionary<NSString *, UMLicenseProductFeature *> *_features;
}

@property(readwrite,atomic,assign)  BOOL    productIsPermanentlyAvailable;
@property(readwrite,atomic,assign)  BOOL    productIsTemporaryAvailable;
@property(readwrite,atomic,strong)  NSString *productRenewUrl;
@property(readwrite,atomic,strong)  NSDate  *productStartDate;
@property(readwrite,atomic,strong)  NSDate  *productEndDateDate;
@property(readwrite,atomic,strong)  NSNumber    *productMaxUseCount;
@property(readwrite,atomic,strong)  NSNumber    *productMaxDurationSinceStart;

- (void)addFeature:(UMLicenseProductFeature *)feature;
- (void)removeFeature:(NSString *)feature;
- (UMLicenseProductFeature *)getFeature:(NSString *)name;

@end
