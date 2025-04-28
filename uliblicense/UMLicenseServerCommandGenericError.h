//
//  UMLicenseServerCommandGenericError.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommand.h>

@interface UMLicenseServerCommandGenericError : UMLicenseServerCommand
{
    int         _status;
    NSString    *_error;
}

@property(readwrite,assign) int     status;
@property(readwrite,strong) NSString *error;

@end

