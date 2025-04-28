//
//  UMLicenseServerCommandError.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommandError.h>

NSString *UMLicenseServerCommandErrrorString(UMLicenseServerCommandError err)
{
    switch(err)
    {
        case UMLicenseServerCommandError_UNDEFINED:
            return @"(undefined)";
        case UMLicenseServerCommandError_NO_ERROR:
            return @"NO_ERROR";
        case UMLicenseServerCommandError_UNSUPPORTED_COMMAND:
            return @"UNSUPPORTED_COMMAND";
        case UMLicenseServerCommandError_PARAMETER_ERROR:
            return @"PARAMETER_ERROR";
        case UMLicenseServerCommandError_INVALID_STATE:
            return @"INVALID_STATE";
        case UMLicenseServerCommandError_INVALID_INSTANCE:
            return @"INVALID_INSTANCE";
        case UMLicenseServerCommandError_NOT_AUTHORIZED:
            return @"NOT_AUTHORIZED";
        case UMLicenseServerCommandError_WRITE_FAILURE:
            return @"WRITE_FAILURE";
            break;
        case UMLicenseServerCommandError_INSERT_FAILURE:
            return @"INSERT_FAILURE";
            break;
        case UMLicenseServerCommandError_UPDATE_FAILURE:
            return @"UPDATE_FAILURE";
            break;
        case UMLicenseServerCommandError_LOAD_FAILURE:
            return @"LOAD_FAILURE";
            break;
        case UMLicenseServerCommandError_NOT_FOUND:
            return @"NOT_FOUND";
            break;
        case UMLicenseServerCommandError_DELETE_FAILURE:
            return @"DELETE_FAILURE";
            break;
        case UMLicenseServerCommandError_API_VERSION_MISMATCH:
            return @"API_VERSION_MISMATCH";
            break;
        case UMLicenseServerCommandError_NO_DB_SESSIONS_AVAILABLE:
            return @"NO_DB_SESSIONS_AVAILABLE";
            break;
    }
    return NULL;
}

