//
//  UMLicenseServerCommandError.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>


typedef enum UMLicenseServerCommandError
{
    UMLicenseServerCommandError_UNDEFINED           = -1,
    UMLicenseServerCommandError_NO_ERROR            = 0,
    UMLicenseServerCommandError_UNSUPPORTED_COMMAND = 1,
    UMLicenseServerCommandError_PARAMETER_ERROR     = 2,
    UMLicenseServerCommandError_INVALID_STATE       = 3,
    UMLicenseServerCommandError_INVALID_INSTANCE    = 4,
    UMLicenseServerCommandError_NOT_AUTHORIZED      = 5,
    UMLicenseServerCommandError_WRITE_FAILURE       = 6,
    UMLicenseServerCommandError_INSERT_FAILURE      = 7,
    UMLicenseServerCommandError_UPDATE_FAILURE      = 8,
    UMLicenseServerCommandError_LOAD_FAILURE        = 9,
    UMLicenseServerCommandError_NOT_FOUND           = 10,
    UMLicenseServerCommandError_DELETE_FAILURE      = 11,
    UMLicenseServerCommandError_API_VERSION_MISMATCH = 12,
    UMLicenseServerCommandError_NO_DB_SESSIONS_AVAILABLE = 13,

} UMLicenseServerCommandError;

NSString *UMLicenseServerCommandErrrorString(UMLicenseServerCommandError err);
