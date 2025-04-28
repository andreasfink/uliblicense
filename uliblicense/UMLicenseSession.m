//
//  UMLicenseServerSession.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseSession.h>
#import <uliblicense/UMLicenseServer.h>
#import <uliblicense/UMLicenseHandler.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>
#import <uliblicense/UMLicenseServerCommand.h>
#import <uliblicense/UMLicenseServerCommandError.h>
#import <uliblicense/UMLicenseServerCommandGenericError.h>
#import <uliblicense/UMLicenseServerCommandHeartBeatRequest.h>
#import <uliblicense/UMLicenseServerCommandHeartBeatResponse.h>
#import <uliblicense/UMLicenseServerCommandGetLicenseRequest.h>
#import <uliblicense/UMLicenseServerCommandGetLicenseResponse.h>
#import <uliblicense/UMLicenseSessionCompletionObject.h>
#import <uliblicense/UMLicense.h>

@implementation UMLicenseSession

- (UMLicenseSession *)init
{
    self = [super init];
    if(self)
    {
        _lastSequenceNumber = 0;
        _lock = [[UMMutex alloc]initWithName:@"ummessage-session"];
        _handshakeTimer = [[UMTimer alloc]initWithTarget:self
                                                selector:@selector(doHandshake)
                                                  object:NULL
                                                 seconds:10
                                                    name:NULL
                                                 repeats:YES
                                         runInForeground:YES];
        _serverApiVersion = 1;
        _clientApiVersion = 1;
        _serverName = @"umlic-srv";
        _clientName = @"umlic-cli";
        _pendingSequences = [[UMSynchronizedDictionary alloc]init];
    }
    return self;
}

- (NSInteger)getSequenceNumber
{
    NSInteger i;
    ummutex_lock(_lock);
    i = _lastSequenceNumber+1;
    if(i > 0x7FFF)
    {
        i=1;
    }
    _lastSequenceNumber = i;
    ummutex_unlock(_lock);
    return i;
}

- (void)doHandshake
{
    UMLicenseServerCommandHeartBeatRequest *req = [[UMLicenseServerCommandHeartBeatRequest alloc]init];
    req.sequenceNumber = [self getSequenceNumber];
    [self sendCommand:req];
    _lastHandshakeRequested = [NSDate date];
}

- (int)processGenericError:(UMLicenseServerCommandGenericError *)cmd
{
    NSString *s = [NSString stringWithFormat:@"%@",cmd.objectValue];
    fprintf(stderr,"GENERIC_ERROR %s",s.UTF8String);
    return cmd.status;
}

- (int)processHeartbeatRequest:(UMLicenseServerCommandHeartBeatRequest *)cmd
{
    UMLicenseServerCommandHeartBeatResponse *res = [[UMLicenseServerCommandHeartBeatResponse alloc]init];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err;
    err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processHeartbeatResponse:(UMLicenseServerCommandHeartBeatResponse *)cmd
{
    _lastHandshakeReceived = [NSDate date];
    return 0;
}


- (int)processGetLicenseRequest:(UMLicenseServerCommandGetLicenseRequest *)cmd
{
    UMLicenseServerCommandGetLicenseResponse *res = [[UMLicenseServerCommandGetLicenseResponse alloc]init];
    [_server getLicenseForRequest:cmd response:res];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processGetLicenseResponse:(UMLicenseServerCommandGetLicenseResponse *)cmd
{
    return 0;
}

- (int)processCommand:(UMLicenseServerCommand *)cmd /* return error code*/
{
    UMLicenseServerCommandType cid = (UMLicenseServerCommandType)cmd.command;
    switch(cid)
    {
        case UMLicenseServerCommand_GENERIC_ERROR_RESPONSE:
        {
            UMLicenseServerCommandGenericError *cmd1 = [[UMLicenseServerCommandGenericError alloc]initWithASN1Object:cmd context:NULL];
            return [self processGenericError:cmd1];
        }
            break;
        case UMLicenseServerCommand_HEARTBEAT_REQUEST:
        {
            UMLicenseServerCommandHeartBeatRequest *cmd1 = [[UMLicenseServerCommandHeartBeatRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatRequest:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommand_HEARTBEAT_RESPONSE:
        {
            UMLicenseServerCommandHeartBeatResponse *cmd1 = [[UMLicenseServerCommandHeartBeatResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatResponse:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommand_GET_LICENSE_REQUEST:
        {
            UMLicenseServerCommandGetLicenseRequest *cmd1 = [[UMLicenseServerCommandGetLicenseRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetLicenseRequest:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommand_GET_LICENSE_RESPONSE:
        {
            UMLicenseServerCommandGetLicenseResponse *cmd1 = [[UMLicenseServerCommandGetLicenseResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetLicenseResponse:cmd1];
        }
            break;
            
        default:
        {
            UMLicenseServerCommandGenericError *cmd1 = [[UMLicenseServerCommandGenericError alloc]initWithASN1Object:cmd context:NULL];
            cmd1.status = UMLicenseServerCommandError_UNSUPPORTED_COMMAND;
            cmd1.error = @"Unknown command";
            [self sendCommand:cmd1];
            return -1;
        }
    }
    return 0;
}

- (UMSocketError)sendCommand:(UMLicenseServerCommand *)cmd
{
    if(_server)
    {
        NSLog(@"Server Sending %@",cmd.objectValue.jsonString);
    }
    if(_client)
    {
        NSLog(@"Client Sending %@",cmd.objectValue.jsonString);
    }
    NSData *data = [cmd berEncoded];
    UMSocketError err = [_socket sendData:data];
    int count=0;
    while((err==UMSocketError_try_again) && (count++ < 10))
    {
        usleep(100);
        err = [_socket sendData:data];
    }
    return err;
}

- (BOOL) awaitsResponses
{
    if(_pendingSequences.count > 0)
    {
        return YES;
    }
    return NO;
}



- (void)startHeartbeat
{
    [_handshakeTimer start];
}

- (void)stopHeartbeat
{
    [_handshakeTimer stop];
}

- (UMLicenseServerCommandError)getLicenseForApplication:(NSString *)application
                                               instance:(NSString *)instance
                                                 serial:(NSString *)serial
                                           macaddresses:(NSString *)macAdresses
                                            ipaddresses:(NSString *)ipAdresses
                                 onCompletionCallObject:(id)callbackObj
                                           withSelector:(SEL)selector
{
    if((callbackObj) && (selector))
    {
        if(![callbackObj respondsToSelector:selector])
        {
            UMAssert(0,@"Object does not respond to selector");
        }
    }
    NSInteger seq = [self getSequenceNumber];
        
    UMLicenseSessionCompletionObject *co = [[UMLicenseSessionCompletionObject alloc]init];
    co.objectToCall = callbackObj;
    co.selectorToCall = selector;
        
    UMLicenseServerCommandGetLicenseRequest *req = [[UMLicenseServerCommandGetLicenseRequest alloc]init];
    req.sequenceNumber = seq;
    req.application = application;
    req.instance = instance;
    req.serial = serial;
    req.macaddresses = macAdresses;
    req.ipaddresses = ipAdresses;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMLicenseServerCommandError_INVALID_STATE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}
/*
- (UMLicenseServerCommandError)doGetLicenseForApplication:(NSString *)application
                                                 instance:(NSString *)instance
                                                   serial:(NSString *)serial
                                             macaddresses:(NSString *)macAdresses
                                              ipaddresses:(NSString *)ipAdresses
                                   onCompletionCallObject:(id)completionHandler
                                             withSelector:(SEL)selector
{
    
}
*/
@end
