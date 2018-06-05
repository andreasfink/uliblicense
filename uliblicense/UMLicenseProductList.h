//
//  UMLicenseProductList.h
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import <ulibasn1/ulibasn1.h>

@class UMLicenseProduct;
@interface UMLicenseProductList : UMASN1Sequence
{
    UMSynchronizedSortedDictionary *_productDict;
}

- (void)addProduct:(UMLicenseProduct *)product;
- (void)removeProduct:(NSString *)productName;
- (UMLicenseProduct *)getProduct:(NSString *)productName;

@end
