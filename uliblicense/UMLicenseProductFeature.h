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
    NSString  *_featureName;
    NSData    *_featureData;
}


@property(readwrite,atomic,strong)  NSString *featureName;
@property(readwrite,atomic,strong)  NSData   *featureData;

@end
