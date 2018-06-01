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

@end
