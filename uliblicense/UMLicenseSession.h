//
//  UMLicenseSession.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>

#import <uliblicense/UMLicenseCommandHandlerProtocol.h>
#import <uliblicense/UMLicenseServerCommandError.h>

@class UMLicenseServer;
@class UMLicenseClient;
@class UMLicenseHandler;
@class UMLicense;


@interface UMLicenseSession : UMObject<UMLicenseCommandHandlerProtocol>
{
    UMSocket            *_socket;
    UMLicenseServer     *_server;
    UMLicenseClient     *_client;
    UMLicenseHandler    *_handler;
    NSString            *_rootDirectory;
    NSString            *_instance;
    BOOL                _authenticated;
    NSString            *_username;
    NSString            *_password;
    NSDate              *_lastHandshakeRequested;
    NSDate              *_lastHandshakeResponse;
    NSDate              *_lastHandshakeReceived;
    UMTimer             *_handshakeTimer;
    UMMutex             *_lock;
    NSInteger           _lastSequenceNumber;
    NSString            *_clientName;
    NSInteger           _clientApiVersion;
    NSString            *_serverName;
    NSInteger           _serverApiVersion;
    BOOL                _clientSuccessfullyLoggedIn;
    UMSynchronizedDictionary *_pendingSequences; /* dictionary key=NSNumber(SequenceNumber) value:UMLicenseSessionCompletionObject */
}

@property(readwrite,strong,atomic)  UMSocket            *socket;
@property(readwrite,strong,atomic)  UMLicenseServer     *server;
@property(readwrite,strong,atomic)  UMLicenseClient     *client;
@property(readwrite,strong,atomic)  UMLicenseHandler    *handler;
@property(readwrite,strong,atomic)  NSString            *rootDirectory;
@property(readwrite,strong,atomic)  NSDate              *lastHandshakeRequested;
@property(readwrite,strong,atomic)  NSDate              *lastHandshakeResponse;
@property(readwrite,strong,atomic)  NSDate              *lastHandshakeReceived;

- (int)processCommand:(UMLicenseServerCommand *)cmd; /* return error code*/

- (UMLicenseServerCommandError)getLicenseForApplication:(NSString *)application
                                               instance:(NSString *)instance
                                                 serial:(NSString *)serial
                                           macaddresses:(NSString *)macAdresses
                                            ipaddresses:(NSString *)ipAdresses
                                 onCompletionCallObject:(id)callbackObj
                                           withSelector:(SEL)selector;

- (BOOL) awaitsResponses;
- (void) startHeartbeat;
- (void) stopHeartbeat;

@end

