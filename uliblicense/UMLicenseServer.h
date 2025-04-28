//
//  UMLicenseServer.h
//  mmlicense-server
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>

@interface UMLicenseServer : UMBackgrounder
{
    NSInteger           _port;
    UMSocket            *_listener;
    UMSynchronizedArray *_incomingConnections; /* array of UMLicenseHandler objects */
    NSString            *_rootDirectory;
    id                  _getLicenseDelegate;
}

@property(readwrite,strong,atomic)  UMSocket            *listener;
@property(readwrite,strong,atomic)  UMSynchronizedArray *incomingConnections; /* array of UMLicenseHandler objects */
@property(readwrite,strong,atomic)  NSString            *rootDirectory;
@property(readwrite,strong,atomic)  id                  getLicense;


- (UMLicenseServer *)initWithPort:(NSInteger)port;
@end

