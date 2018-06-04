//
//  UMLicense.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>

@class UMLicenseProducts;
@class UMLicenseRestriction;
@class UMLicenseRestrictionList;

@interface UMLicense : UMASN1Sequence
{
    NSString *_licenseSerialNumber;
    NSString *_licenseType;
    NSString *_licenseOwner;
    UMLicenseRestrictionList *_licenseRestrictions;
    NSDate *_licenseExpiration;
    NSString *_licenseRenewUrl;
    NSMutableDictionary<NSString *, UMLicenseProducts *> *_products;
}

@property(readwrite,strong)  NSString *licenseSerialNumber;
@property(readwrite,strong)  NSString *licenseType;
@property(readwrite,strong)  NSString *licenseOwner;
@property(readwrite,strong)  UMLicenseRestrictionList *licenseRestrictions;
@property(readwrite,strong)  NSDate *licenseExpiration;
@property(readwrite,strong)  NSString *licenseRenewUrl;
@property(readwrite,strong)  NSMutableDictionary<NSString *, UMLicenseProducts *> *products;

@end
