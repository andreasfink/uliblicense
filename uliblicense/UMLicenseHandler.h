//
//  UMLicenseHandler.h
//  mmlicense-server
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>

#import "UMLicenseCommandHandlerProtocol.h"
@class UMLicenseSession;
@class UMLicenseServer;
@class UMLicenseClient;

@interface UMLicenseHandler : UMBackgrounder
{
    UMSocket *               _socket;
    int                      _maxReceiveBuffer;
    UMLicenseSession         *_session;
    UMLicenseServer          *_server;
    UMLicenseClient          *_client;
}

@property(readwrite,strong,atomic)  id<UMLicenseCommandHandlerProtocol> commandHandlerDelegate;
@property(readwrite,strong,atomic)  UMLicenseSession *session;

- (UMLicenseHandler *)initWithSocket:(UMSocket *)s server:(UMLicenseServer *)server;
- (UMLicenseHandler *)initWithSocket:(UMSocket *)s client:(UMLicenseClient *)client;

@end

