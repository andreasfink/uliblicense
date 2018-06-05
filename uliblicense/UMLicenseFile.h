//
//  UMLicenseFile.h
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import <ulib/ulib.h>

@class UMLicense;
@class UMSignedLicense;
@interface UMLicenseFile : UMObject
{
    UMSignedLicense *_signedLicense;
    NSString *_filename;
}

@property(readwrite,strong) UMSignedLicense *signedLicense;
@property(readwrite,strong) NSString *filename;

- (UMLicenseFile *)initWithFilename:(NSString *)filename;

@end

