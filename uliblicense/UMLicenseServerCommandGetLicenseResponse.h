//
//  UMLicenseServerCommandGetLicenseResponse.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommand.h>


@interface UMLicenseServerCommandGetLicenseResponse : UMLicenseServerCommand
{
    NSData *_license;
}
@property(readwrite,atomic,strong)  NSData *license;

@end

