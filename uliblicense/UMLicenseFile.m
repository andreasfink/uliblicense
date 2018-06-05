//
//  UMLicenseFile.m
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import "UMLicenseFile.h"
#import "UMSignedLicense.h"
#import "UMLicense.h"
#import "UMEncryptedLicense.h"

@implementation UMLicenseFile


- (UMLicenseFile *)initWithFilename:(NSString *)filename
{
    self = [super init];
    if(self)
    {
        _filename = filename;
        NSData *d = [NSData dataWithContentsOfFile:filename];
        if(d==NULL)
        {
            return NULL;
        }
        NSUInteger i=0;
        UMASN1Object *o = [[UMASN1Object alloc]initWithBerData:d atPosition:&i context:NULL];
        UMSignedLicense *slic = [[UMSignedLicense alloc]initWithASN1Object:o context:NULL];
        if(slic == NULL)
        {
            return NULL;
        }
        _signedLicense = slic;
    }
    return self;
}
@end
