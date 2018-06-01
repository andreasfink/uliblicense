//
//  UMSignedLicense.h
//  mmlic
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulibasn1/ulibasn1.h>
@class UMLicense;

@interface UMSignedLicense : UMASN1Sequence
{
    UMLicense       *_license;
    NSData          *_licenseData;
    NSData          *_signature;
    UMASN1Integer   *_variant;
    NSString        *_plaintext;
}

@property(readwrite,strong) UMLicense       *license;
@property(readwrite,strong) NSData          *signature;
@property(readwrite,strong) UMASN1Integer   *variant;
@property(readwrite,strong) NSString        *plaintext;

@end

