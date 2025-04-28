//
//  UMLicenseClient.h
//  mmlic
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>
#import <uliblicense/UMLicenseServerCommandError.h>

@class UMLicenseHandler;
@class UMLicense;
@class UMLicenseSession;

typedef void (^UMMesssageClientInsertCompletionHandler)(int status,NSString *error);

@interface UMLicenseClient : UMObject
{
    UMSocket            *_socket;
    BOOL                _isConnected;
    UMLicenseSession    *_session;
    UMLicenseHandler    *_handler;
    NSString            *_username;
    NSString            *_password;
    NSString            *_instance;
    BOOL                _loginComplete;
    UMLicenseServerCommandError _loginStatus;
    BOOL                _callComplete;
    UMLicenseServerCommandError _callResult;
    id                  _callResultObject;

}

@property(readwrite,strong,atomic)  NSString *username;
@property(readwrite,strong,atomic)  NSString *password;
@property(readwrite,strong,atomic)  NSString *instance;
@property(readwrite,assign,atomic)  BOOL loginComplete;
@property(readwrite,assign,atomic)  UMLicenseServerCommandError loginStatus;

- (UMLicenseClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
- (UMLicenseServerCommandError)login; /* returns UMLicenseServerCommandError_NO_ERROR if logged in */
- (UMLicenseServerCommandError)insertMessage:(UMLicense *)msg;
- (UMLicenseServerCommandError)getLicenseForApplication:(NSString *)application
                                               instance:(NSString *)instance
                                                 serial:(NSString *)serial
                                           macaddresses:(NSString *)macAdresses
                                            ipaddresses:(NSString *)ipAdresses
                                                license:(UMLicense **)licptr;
- (BOOL) awaitsResponses;
- (void)close;

@end
