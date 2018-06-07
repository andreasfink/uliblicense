//
//  UMLicense.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>

@class UMLicenseProduct;
@class UMLicenseProductList;
@class UMLicenseRestriction;
@class UMLicenseRestrictionList;
@class UMLicenseProductFeature;

#define PERPETUAL_LICENSE_DATE_STRING  @"9999-12-31 23:59:59.999999"

@interface UMLicense : UMASN1Sequence
{
    NSString *_licenseSerialNumber;
    NSString *_licenseType;
    NSString *_licenseOwner;
    NSString *_licenseEmail;
    UMLicenseRestrictionList *_licenseRestrictions;
    NSDate *_licenseExpiration;
    NSString *_licenseRenewUrl;
    NSString *_licenseRenewAddress;
    NSNumber *_licenseRenewTimerMin;
    NSNumber *_licenseRenewTimerMax;
    UMLicenseProductList *_licenseProducts;
    
    /* this is internally used only and not stored in ASN1: */
    NSString *_filename;
}

@property(readwrite,strong)  NSString *licenseSerialNumber;
@property(readwrite,strong)  NSString *licenseType;
@property(readwrite,strong)  NSString *licenseOwner;
@property(readwrite,strong)  UMLicenseRestrictionList *licenseRestrictions;
@property(readwrite,strong)  NSDate *licenseExpiration;
@property(readwrite,strong)  NSString *licenseRenewUrl;
@property(readwrite,strong)  NSString *licenseRenewAddress;
@property(readwrite,strong)  UMLicenseProductList *licenseProducts;
@property(readwrite,strong)  NSString *filename;
@property(readwrite,strong)  NSNumber *licenseRenewTimerMin;
@property(readwrite,strong)  NSNumber *licenseRenewTimerMax;

- (void)addProduct:(UMLicenseProduct *)product;
- (void)addRestriction:(UMLicenseRestriction *)rest;
- (UMLicenseProductFeature *)getProduct:(NSString *)product feature:(NSString *)feature;

@end
