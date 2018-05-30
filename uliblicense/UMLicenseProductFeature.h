//
//  UMLicenseProductFeature.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import "UMLicenseProduct.h"

@interface UMLicenseProductFeature : UMObject
{
    NSString *_productName;
    NSString *_featureName;
    BOOL    _featureIsPermanentlyAvailable;
    BOOL    _featureIsTemporaryAvailable;
    NSString *_featureRenewUrl;
    NSDate  *_featureStartDate;
    NSDate  *_featureEndDateDate;
    NSNumber    *_featureMaxUseCount;
    NSNumber    *_featureMaxDurationSinceStart;
    NSMutableDictionary *_featureSpecificDict;
}


@property(readwrite,atomic,strong)  NSString *productName;
@property(readwrite,atomic,strong)  NSString *featureName;

@property(readwrite,atomic,assign)  BOOL    featureIsPermanentlyAvailable;
@property(readwrite,atomic,assign)  BOOL    featureIsTemporaryAvailable;
@property(readwrite,atomic,strong)  NSString *featureRenewUrl;
@property(readwrite,atomic,strong)  NSDate  *featureStartDate;
@property(readwrite,atomic,strong)  NSDate  *featureEndDateDate;
@property(readwrite,atomic,strong)  NSNumber    *featureMaxUseCount;
@property(readwrite,atomic,strong)  NSNumber    *featureMaxDurationSinceStart;
@property(readwrite,atomic,strong)  NSMutableDictionary *featureSpecificDict;

@end
