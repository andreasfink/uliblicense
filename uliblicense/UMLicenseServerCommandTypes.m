//
//  UMLIcenseServerCommandTypes.m
//  mmlic
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <Foundation/Foundation.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>

NSString *UMLicenseServerCommandTypeString(UMLicenseServerCommandType t)
{
    switch(t)
    {
        case UMLicenseServerCommand_GENERIC_ERROR_RESPONSE:
            return @"GENERIC_ERROR_RESPONSE";
        case UMLicenseServerCommand_HEARTBEAT_REQUEST:
            return @"HEARTBEAT_REQUEST";
        case UMLicenseServerCommand_HEARTBEAT_RESPONSE:
            return @"HEARTBEAT_RESPONSE";
        case UMLicenseServerCommand_GET_LICENSE_REQUEST:
            return @"INSERT_MESSAGE_REQUEST";
        case UMLicenseServerCommand_GET_LICENSE_RESPONSE:
            return @"GET_LICENSE_RESPONSE";
    }
    return NULL;
}

