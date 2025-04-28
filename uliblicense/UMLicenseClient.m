//
//  UMLicenseClient.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseClient.h>
#import <uliblicense/UMLicenseHandler.h>
#import <uliblicense/UMLicense.h>
#import <uliblicense/UMLicenseSession.h>
#import <uliblicense/UMLicenseServerCommandGetLicenseResponse.h>
#import <uliblicense/UMLicenseServerCommandError.h>

@implementation UMLicenseClient

- (UMLicenseClient *)initWithHost:(UMHost *)host port:(int)port
{
    self = [super init];
    if(self)
    {
        [host resolve];
        _socket = [[UMSocket alloc]initWithType:UMSOCKET_TYPE_TCP];
        _socket.remoteHost = host;
        _socket.requestedRemotePort = port;
    }
    return self;
}

- (BOOL)connect
{
    if(_isConnected==NO)
    {
        UMSocketError err = [_socket connect];
        if(err==UMSocketError_no_error)
        {
            _isConnected = YES;
            _handler  = [[UMLicenseHandler alloc]initWithSocket:_socket client:self];
            _session = _handler.session;
            [_handler startBackgroundTask];
        }
        else
        {
            NSLog(@"connect failed with error %d (%@)",err,[UMSocket getSocketErrorString:err]);
        }
    }
    return _isConnected;
}



- (UMLicenseServerCommandError)getLicenseForApplication:(NSString *)application
                                               instance:(NSString *)instance
                                                 serial:(NSString *)serial
                                           macaddresses:(NSString *)macAdresses
                                            ipaddresses:(NSString *)ipAdresses
                                                license:(UMLicense **)licptr
{
    _callComplete = NO;
    UMLicenseServerCommandError e = [_session getLicenseForApplication:(NSString *)application
                                                              instance:(NSString *)instance
                                                                serial:(NSString *)serial
                                                          macaddresses:(NSString *)macAdresses
                                                           ipaddresses:(NSString *)ipAdresses
                                                onCompletionCallObject:self
                                                          withSelector:@selector(getLicenseCompletionHandler:)];
    if(e != UMLicenseServerCommandError_NO_ERROR)
    {
        return e;
    }
    while(_callComplete==NO)
    {
        usleep(1000);
    }
    if(licptr)
    {
        *licptr = _callResultObject;
    }
    return _callResult;
}

- (void)getLicenseCompletionHandler:(UMLicenseServerCommandGetLicenseResponse *)cmd
{
    _callResult = cmd.status;
    _callResultObject = cmd.license;
    _callComplete = YES;
}



- (BOOL) awaitsResponses
{
    return [_session awaitsResponses];
}

- (void)close
{
    [_handler shutdownBackgroundTask];
    [_handler.session.socket close];
    _handler.session = NULL;
    _session = NULL;
    _handler = NULL;
}
@end
