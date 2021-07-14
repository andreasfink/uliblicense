//
//  UMLicenseProductFeature.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>
#import "UMLicenseProduct.h"

@interface UMLicenseProductFeature : UMASN1Sequence
{
    NSString    *_featureName;
    NSData      *_featureData;
    /* note: These fields are normally in UMLicense and are copied over into this object
     if its being requested. They are NOT stored inside the ASN1 */
    NSDate      *_licenseExpiration;
    NSString    *_licenseSerialNumber;
    NSString    *_licenseName;
    NSString    *_licenseEmail;
}

@property(readwrite,atomic,strong)  NSString    *featureName;
@property(readwrite,atomic,strong)  NSData      *featureData;
@property(readwrite,atomic,strong)  NSDate      *licenseExpiration;
@property(readwrite,atomic,strong)  NSString    *licenseSerialNumber;
@property(readwrite,atomic,strong)  NSString    *licenseName;
@property(readwrite,atomic,strong)  NSString    *licenseEmail;

- (UMLicenseProductFeature *)initWithName:(NSString *)name;
- (BOOL)isAvailable;
- (double)doubleValue;
- (void)setDoubleValue:(double)val;
@end
