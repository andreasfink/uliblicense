//
//  UMLicenseServerCommandTypes.h
//  mmlic
//
//  Created by Andreas Fink on 28.04.2025.
//


typedef enum UMLicenseServerCommandType
{
    UMLicenseServerCommand_GENERIC_ERROR_RESPONSE        = 1,
    UMLicenseServerCommand_HEARTBEAT_REQUEST             = 2,
    UMLicenseServerCommand_HEARTBEAT_RESPONSE            = 3,
    UMLicenseServerCommand_GET_LICENSE_REQUEST           = 101,
    UMLicenseServerCommand_GET_LICENSE_RESPONSE          = 102,
} UMLicenseServerCommandType;

NSString *UMLicenseServerCommandTypeString(UMLicenseServerCommandType err);

