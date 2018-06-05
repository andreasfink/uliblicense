//
//  UMLicenseProductList.m
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import "UMLicenseProductList.h"
#import "UMLicenseProduct.h"

@implementation UMLicenseProductList

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    if(_productDict)
    {
        NSArray *_productDictKey = [_productDict allKeys];
        for(id key in _productDictKey)
        {
            UMLicenseProduct *p = _productDict[key];
            [p processBeforeEncode];
            p.asn1_tag.tagNumber = 0;
            p.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
            [asn1_list addObject:p];
        }
    }
}


- (UMLicenseProductList *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    _productDict = [[UMSynchronizedSortedDictionary alloc]init];
    while(o)
    {
        if((o.asn1_tag.tagNumber == 0) && (o.asn1_tag.tagClass == UMASN1Class_ContextSpecific))
        {
            UMLicenseProduct *prod = [[UMLicenseProduct alloc]initWithASN1Object:o context:context];
            if(prod.productName)
            {
                _productDict[prod.productName] = prod;
            }
        }
        o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (void)addProduct:(UMLicenseProduct *)product
{
    if(product.productName)
    {
        if(_productDict==NULL)
        {
            _productDict = [[UMSynchronizedSortedDictionary alloc]init];
        }
        _productDict[product.productName] = product;
    }
}

- (void)removeProduct:(NSString *)productName
{
    [_productDict removeObjectForKey:productName];

}
- (UMLicenseProduct *)getProduct:(NSString *)productName
{
    return _productDict[productName];

}

- (NSString *) objectName
{
    return @"UMLicenseProductList";
}

- (id) objectValue
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSArray *keys = [_productDict allKeys];
    for(NSString *key in keys)
    {
        UMLicenseProduct *p = _productDict [key];
        [arr addObject:p.objectValue];
    }
    return arr;
}

@end

