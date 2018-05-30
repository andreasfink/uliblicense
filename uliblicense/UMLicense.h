//
//  UMLicense.h
//  uliblicense
//
//  Created by Andreas Fink on 30.05.18.
//  Copyright © 2018 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>
@class UMLicenseProducts;

@interface UMLicense : UMObject
{
    NSMutableDictionary<NSString *, UMLicenseProducts *> *_products;
}

@end
