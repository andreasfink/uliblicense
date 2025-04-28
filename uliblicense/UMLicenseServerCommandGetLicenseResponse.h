//
//  UMLicenseServerCommandGetLicenseResponse.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommand.h>
#import <uliblicense/UMLicenseServerCommandError.h>

@interface UMLicenseServerCommandGetLicenseResponse : UMLicenseServerCommand
{
    UMLicenseServerCommandError     _status;
    NSString                        *_error;
    NSData                          *_license;
}
@property(readwrite,atomic,assign)  UMLicenseServerCommandError status;
@property(readwrite,atomic,strong)  NSString *error;
@property(readwrite,atomic,strong)  NSData   *license;

@end

