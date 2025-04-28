//
//  UMLicenseServerCommandGetLicenseRequest.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommand.h>

@interface UMLicenseServerCommandGetLicenseRequest : UMLicenseServerCommand
{
    NSString *_application;
    NSString *_instance;
    NSString *_serial;
    NSString *_macaddresses;
    NSString *_ipaddresses;
}
@property(readwrite,atomic,strong)  NSString *application;
@property(readwrite,atomic,strong)  NSString *instance;
@property(readwrite,atomic,strong)  NSString *serial;
@property(readwrite,atomic,strong)  NSString *macaddresses;
@property(readwrite,atomic,strong)  NSString *ipaddresses;

@end
