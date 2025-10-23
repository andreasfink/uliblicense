//
//  UMLicenseHandler.m
//  mmlicense-server
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseHandler.h>
#import <uliblicense/UMLicenseSession.h>
#import <uliblicense/UMLicenseServer.h>
#import <uliblicense/UMLicenseClient.h>
#import <uliblicense/UMLicenseServerCommand.h>

@implementation UMLicenseHandler


- (UMLicenseHandler *)initWithSocket:(UMSocket *)s server:(UMLicenseServer *)server
{
    self = [super initWithName:@"UMLicenseHandler"];

    if(self)
    {
        _socket = s;
        _server = server;
        _maxReceiveBuffer = 10485760; /* 10MB */
        _session = [[UMLicenseSession alloc]init];
        _session.socket = _socket;
        _session.server = _server;
        _session.rootDirectory = _server.rootDirectory;
        
    }
    return self;
}

- (UMLicenseHandler *)initWithSocket:(UMSocket *)s client:(UMLicenseClient *)client
{
    self = [super initWithName:@"UMLicenseHandler"];

    if(self)
    {
        _socket = s;
        _client = client;
        _maxReceiveBuffer = 10485760; /* 10MB */
        _session = [[UMLicenseSession alloc]init];
        _session.socket = _socket;
        _session.client = _client;
        _session.rootDirectory = _server.rootDirectory;
    }
    return self;
}

- (void)backgroundInit
{
}

- (void)backgroundExit
{
    [_socket close];
}

- (int)work
{
    int processedData = 0;
    @autoreleasepool
    {
        UMSocketError err =  [_socket receiveToBufferWithBufferLimit:_maxReceiveBuffer];
        if( (err != UMSocketError_has_data) &&
            (err != UMSocketError_has_data_and_hup) &&
            (err != UMSocketError_no_error) &&
            (err != UMSocketError_try_again))
        {
            /* some unexpected error occured */
            NSLog(@"error while reading %@",[UMSocket getSocketErrorString:err]);
            [self shutdownBackgroundTaskFromWithin];
            return processedData;
        }
        ummutex_lock(_socket.dataLock);
        @try
        {
            NSUInteger pos = 0;
            if(_socket.receiveBuffer.length > 0)
            {
                UMASN1Object *o = [[UMASN1Object alloc]initWithBerData:_socket.receiveBuffer atPosition:&pos context:NULL];
                if(pos > 0)
                {
                    [_socket deleteFromReceiveBuffer:pos];
                    processedData++;
                }
                if(o)
                {
                    UMLicenseServerCommand *cmd = [[UMLicenseServerCommand alloc]initWithASN1Object:o context:NULL];
                    if(cmd)
                    {
                        int err = [_session processCommand:cmd];
                        if(err)
                        {
                            [self terminateHandler];
                        }
                        else
                        {
                            processedData++;
                        }
                    }
                }
            }
        }
        @catch(NSException *e)
        {
            NSLog(@"e=%@",e);
        }
        ummutex_unlock(_socket.dataLock);
        if(err == UMSocketError_has_data_and_hup)
        {
            [self terminateHandler];
        }
    }
    return processedData;
}

- (void) terminateHandler
{
    _session.socket = NULL;
    _session.server = NULL;
    _session.client = NULL;
    _session = NULL;
    [self shutdownBackgroundTaskFromWithin];
}
@end
