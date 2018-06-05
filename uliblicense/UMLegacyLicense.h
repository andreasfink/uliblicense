//
//  UMLegacyLicense.h
//  uliblicense
//
//  Created by Andreas Fink on 04.06.18.
//

#import <ulib/ulib.h>

@interface UMLegacyLicense : UMObject
{
    NSData *_plaintext;
    NSData *_ciphertext;
}

@property(readwrite,strong)     NSData *plaintext;
@property(readwrite,strong)     NSData *ciphertext;

- (void)encrypt;
- (void)decrypt;
@end
