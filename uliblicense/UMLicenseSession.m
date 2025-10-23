//
//  UMLicenseServerSession.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseSession.h>

@implementation UMLicenseSession


//
//  UMLicenseSession.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <uliblicense/UMLicenseSession.h>
#import <uliblicense/UMLicenseServer.h>
#import <uliblicense/UMLicenseHandler.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>
#import <uliblicense/UMLicenseServerCommand.h>
#import <uliblicense/UMLicenseServerCommandError.h>
#import <uliblicense/UMLicenseServerCommandGenericError.h>
#import <uliblicense/UMLicenseServerCommandHeartbeatRequest.h>
#import <uliblicense/UMLicenseServerCommandHeartbeatResponse.h>
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
        _serverName = @"umserver";
        _clientName = @"umcli";
        _pendingSequences = [[UMSynchronizedDictionary alloc]init];
        _username = @"testuser";
        _password = @"testpass";
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
    UMLicenseServerCommandHeartbeatRequest *req = [[UMLicenseServerCommandHeartbeatRequest alloc]init];
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

- (int)processHeartbeatRequest:(UMLicenseServerCommandHeartbeatRequest *)cmd
{
    UMLicenseServerCommandHeartbeatResponse *res = [[UMLicenseServerCommandHeartbeatResponse alloc]init];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err;
    err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processHeartbeatResponse:(UMLicenseServerCommandHeartbeatResponse *)cmd
{
    _lastHandshakeReceived = [NSDate date];
    return 0;
}

- (int)processLoginRequest:(UMLicenseServerCommandLoginRequest *)cmd
{
    UMLicenseServerCommandError error = [_server.authenticationDelegate login:cmd.username
                                                                     password:cmd.password
                                                                         host:_socket.connectedRemoteAddress
                                                                     instance:cmd.instance];
    UMLicenseServerCommandLoginResponse *res = [[UMLicenseServerCommandLoginResponse alloc]init];
    if(error ==UMLicenseServerCommandError_NO_ERROR)
    {
        _authenticated = YES;
        _instance = cmd.instance;
    }
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    res.apiVersion = _serverApiVersion;
    res.serverName = _serverName;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processLoginResponse:(UMLicenseServerCommandLoginResponse *)cmd
{
    NSNumber *seq = @(cmd.sequenceNumber);
    if(cmd.serverName)
    {
        _serverName = cmd.serverName;
    }
    _serverApiVersion = cmd.apiVersion;
    if(cmd.status == UMLicenseServerCommandError_NO_ERROR)
    {
        _clientSuccessfullyLoggedIn = YES;
    }
    else
    {
        _clientSuccessfullyLoggedIn = NO;
    }
    
    UMLicenseSessionCompletionObject *co =_pendingSequences[seq];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [co.objectToCall performSelector:co.selectorToCall withObject:cmd];
#pragma clang diagnostic pop
    return 0;
}

- (int)processInsertMessageRequest:(UMLicenseServerCommandInsertMessageRequest *)cmd
{
    UMLicenseServerCommandError error;
    if(_server.insertOrUpdateMessageDelegate)
    {
        error = [_server.insertOrUpdateMessageDelegate insertOrUpdateMessage:cmd.message];
    }
    else
    {
        error = [self localInsertMessage:cmd.message];
    }
    UMLicenseServerCommandInsertMessageResponse *res = [[UMLicenseServerCommandInsertMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processInsertMessageResponse:(UMLicenseServerCommandInsertMessageResponse *)cmd
{
    NSNumber *seq = @(cmd.sequenceNumber);
    
    UMLicenseSessionCompletionObject *co = _pendingSequences[seq];
    if(co)
    {
        [_pendingSequences removeObjectForKey:seq];
        {
            if(co.objectToCall)
            {
                if([co.objectToCall respondsToSelector:co.selectorToCall])
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [co.objectToCall performSelector:co.selectorToCall withObject:cmd];
                }
#pragma clang diagnostic pop
            }
        }
    }
    return 0;
}

- (int)processUpdateMessageRequest:(UMLicenseServerCommandUpdateMessageRequest *)cmd
{
    UMLicenseServerCommandError error;
    if(_server.updateMessageDelegate)
    {
        error = [_server.updateMessageDelegate updateMessage:cmd.message];
    }
    else if (_server.insertOrUpdateMessageDelegate)
    {
        error = [_server.insertOrUpdateMessageDelegate insertOrUpdateMessage:cmd.message];
    }
    else
    {
        error = [self localUpdateMessage:cmd.message];
    }
    UMLicenseServerCommandUpdateMessageResponse *res = [[UMLicenseServerCommandUpdateMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processUpdateMessageResponse:(UMLicenseServerCommandUpdateMessageResponse *)cmd
{
    return 0;
}

- (int)processGetMessageRequest:(UMLicenseServerCommandGetMessageRequest *)cmd
{
    UMLicenseServerCommandGetMessageResponse *res = [[UMLicenseServerCommandGetMessageResponse alloc]init];
    if(!_authenticated)
    {
        res.status = UMLicenseServerCommandError_NOT_AUTHORIZED;
        res.sequenceNumber = cmd.sequenceNumber;
    }
    else
    {
        UMLicense *msg;
        UMLicenseServerCommandError err = UMLicenseServerCommandError_NO_ERROR;
        if(_server.getMessageDelegate)
        {
            msg = [_server.getMessageDelegate getMessage:cmd.messageId instance:cmd.instance error:&err];
        }
        else
        {
            msg = [self localGetMessage:cmd.messageId instance:cmd.instance error:&err];
        }
        res.status = err;
        if(err==UMLicenseServerCommandError_NO_ERROR)
        {
            res.message = msg;
        }
    }
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processGetMessageResponse:(UMLicenseServerCommandGetMessageResponse *)cmd
{
    return 0;
}

- (int)processDeleteMessageRequest:(UMLicenseServerCommandDeleteMessageRequest *)cmd
{
    UMLicenseServerCommandError error = UMLicenseServerCommandError_NO_ERROR;
    if(_server.deleteMessageDelegate)
    {
        error = [_server.deleteMessageDelegate deleteMessage:cmd.messageId];
    }
    else
    {
        error = [self localDeleteMessage:cmd.messageId];
    }
    UMLicenseServerCommandDeleteMessageResponse *res = [[UMLicenseServerCommandDeleteMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processDeleteMessageResponse:(UMLicenseServerCommandDeleteMessageResponse *)cmd
{
    return 0;
}

- (int)processCommand:(UMLicenseServerCommand *)cmd /* return error code*/
{
    UMLicenseServerCommandType cid = (UMLicenseServerCommandType)cmd.command;
    switch(cid)
    {
        case UMLicenseServerCommandType_GENERIC_ERROR_RESPONSE:
        {
            UMLicenseServerCommandGenericError *cmd1 = [[UMLicenseServerCommandGenericError alloc]initWithASN1Object:cmd context:NULL];
            return [self processGenericError:cmd1];
        }
            break;
        case UMLicenseServerCommandType_HEARTBEAT_REQUEST:
        {
            UMLicenseServerCommandHeartbeatRequest *cmd1 = [[UMLicenseServerCommandHeartbeatRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatRequest:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommandType_HEARTBEAT_RESPONSE:
        {
            UMLicenseServerCommandHeartbeatResponse *cmd1 = [[UMLicenseServerCommandHeartbeatResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatResponse:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommandType_LOGIN_REQUEST:
        {
            UMLicenseServerCommandLoginRequest *cmd1 = [[UMLicenseServerCommandLoginRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processLoginRequest:cmd1];
            
        }
            break;
             
        case UMLicenseServerCommandType_LOGIN_RESPONSE:
        {
            UMLicenseServerCommandLoginResponse *cmd1 = [[UMLicenseServerCommandLoginResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processLoginResponse:cmd1];
        }
            break;
            
        case UMLicenseServerCommandType_INSERT_MESSAGE_REQUEST:
        {
            UMLicenseServerCommandInsertMessageRequest *cmd1 = [[UMLicenseServerCommandInsertMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            int i =  [self processInsertMessageRequest:cmd1];
            return i;
        }
            break;
            
        case UMLicenseServerCommandType_INSERT_MESSAGE_RESPONSE:
        {
            UMLicenseServerCommandInsertMessageResponse *cmd1 = [[UMLicenseServerCommandInsertMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processInsertMessageResponse:cmd1];
        }
            break;
            
        case UMLicenseServerCommandType_UPDATE_MESSAGE_REQUEST:
        {
            UMLicenseServerCommandUpdateMessageRequest *cmd1 = [[UMLicenseServerCommandUpdateMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processUpdateMessageRequest:cmd1];
        }
            break;
            
        case UMLicenseServerCommandType_UPDATE_MESSAGE_RESPONSE:
        {
            UMLicenseServerCommandUpdateMessageResponse *cmd1 = [[UMLicenseServerCommandUpdateMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processUpdateMessageResponse:cmd1];
        }
            break;
        case UMLicenseServerCommandType_GET_MESSAGE_REQUEST:
        {
            UMLicenseServerCommandGetMessageRequest *cmd1 = [[UMLicenseServerCommandGetMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetMessageRequest:cmd1];
            
        }
            break;
            
        case UMLicenseServerCommandType_GET_MESSAGE_RESPONSE:
        {
            UMLicenseServerCommandGetMessageResponse *cmd1 = [[UMLicenseServerCommandGetMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetMessageResponse:cmd1];
        }
            break;
            
        case UMLicenseServerCommandType_DELETE_MESSAGE_REQUEST:
        {
            UMLicenseServerCommandDeleteMessageRequest *cmd1 = [[UMLicenseServerCommandDeleteMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processDeleteMessageRequest:cmd1];
        }
            break;
            
        case UMLicenseServerCommandType_DELETE_MESSAGE_RESPONSE:
        {
            UMLicenseServerCommandDeleteMessageResponse *cmd1 = [[UMLicenseServerCommandDeleteMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processDeleteMessageResponse:cmd1];
            
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


- (UMLicenseServerCommandError) localInsertMessage:(UMLicense *)msg
{
    if(!_authenticated)
    {
        return UMLicenseServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:msg.messageId.stringValue];
    NSString *filename1 = [NSString stringWithFormat:@"%@.json",filename];
    NSString *filename2 = [NSString stringWithFormat:@"%@.ber",filename];
    NSString *s = [[msg objectValue]jsonString];
    NSData *data = [msg berEncoded];
    NSError *err1=NULL;
    NSError *err2=NULL;

    [s writeToFile:filename1 atomically:YES encoding:NSUTF8StringEncoding  error:&err1];
    if(err1)
    {
        NSLog(@"write to file '%@' failed.\n%@\n",filename1,err1);
    }
    [data writeToFile:filename2 options:NSDataWritingAtomic error:&err2];
    if(err2)
    {
        NSLog(@"write to file '%@' failed.\n%@\n",filename2,err2);
        return UMLicenseServerCommandError_WRITE_FAILURE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}

- (UMLicenseServerCommandError) localUpdateMessage:(UMLicense *)msg
{
    if(!_authenticated)
    {
        return UMLicenseServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:msg.messageId.stringValue];
    NSData *data = [msg berEncoded];
    if([data writeToFile:filename atomically:YES])
    {
        NSLog(@"write to file '%@' failed",filename);
        return UMLicenseServerCommandError_UPDATE_FAILURE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}

- (UMLicenseServerCommandError) localDeleteMessage:(NSString *)messageId
{
    if(!_authenticated)
    {
        return UMLicenseServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:messageId];
    if([[NSFileManager defaultManager]isDeletableFileAtPath:filename] == NO)
    {
        return UMLicenseServerCommandError_NOT_FOUND;
        
    }
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:filename
                                               error:&err];
    if(err)
    {
        NSLog(@"delete failed for file '%@'",filename);
        return UMLicenseServerCommandError_DELETE_FAILURE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}


- (UMLicenseServerCommandError) doGetMessage:(NSString *)messageId
                                    instance:(NSString *)instance
                      onCompletionCallObject:(id)obj
                                withSelector:(SEL)sel
{
    if((obj) && (sel))
    {
        if(![obj respondsToSelector:sel])
        {
            UMAssert(0,@"Object does not respond to selector");
        }
    }
    NSInteger seq = [self getSequenceNumber];
    
    UMLicenseSessionCompletionObject *co = [[UMLicenseSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;
    
    UMLicenseServerCommandGetMessageRequest *req = [[UMLicenseServerCommandGetMessageRequest alloc]init];
    req.sequenceNumber = seq;
    req.messageId = messageId;
    req.instance = instance;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMLicenseServerCommandError_INVALID_STATE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}

- (UMLicense *)localGetMessage:(NSString *)messageId instance:(NSString *)instance error:(UMLicenseServerCommandError *)e
{
    if(!_authenticated)
    {
        *e = UMLicenseServerCommandError_NOT_AUTHORIZED;
        return NULL;
    }
    
    NSString *filename = [self messageIdToFileName:messageId instance:instance];
    NSString *filename2 = [NSString stringWithFormat:@"%@.ber",filename];

    NSData *data = [NSData dataWithContentsOfFile:filename];
    if(data)
    {
        UMLicense *msg;
        @try
        {
            msg = [[UMLicense alloc]initWithBerData:data];
        }
        @catch(NSException *ex)
        {
            NSLog(@"exception while loading %@: %@",filename2,ex);
        }
        if(msg)
        {
            *e = UMLicenseServerCommandError_NO_ERROR;
            return msg;
        }
    }
    *e = UMLicenseServerCommandError_LOAD_FAILURE;
    return NULL;
}

- (NSString *)messageIdToFileName:(NSString *)msgid
{
    return [self messageIdToFileName:(NSString *)msgid instance:_instance];
}

- (NSString *)messageIdToFileName:(NSString *)msgid instance:(NSString *)instance
{
    if(msgid.length == 18)
    {
        NSString *year          = [msgid substringWithRange:NSMakeRange(0,4)];
        NSString *month         = [msgid substringWithRange:NSMakeRange(4,2)];
        NSString *day           = [msgid substringWithRange:NSMakeRange(6,2)];
        NSString *hour          = [msgid substringWithRange:NSMakeRange(8,2)];
        NSString *min           = [msgid substringWithRange:NSMakeRange(10,2)];
        NSString *sec           = [msgid substringWithRange:NSMakeRange(12,2)];
        NSString *micro         = [msgid substringWithRange:NSMakeRange(14,4)];
        NSString *hour_tenmin   = [msgid substringWithRange:NSMakeRange(8,3)];

        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",_rootDirectory,instance,year,month,day,hour_tenmin];
        NSString *filename = [NSString stringWithFormat:@"%@/%@-%@-%@_%@:%@:%@.%@",path,year,month,day,hour,min,sec,micro];
        
        NSError *err = NULL;
        [[NSFileManager defaultManager]createDirectoryAtPath:path
                                 withIntermediateDirectories:YES
                                                  attributes:NULL
                                                       error:&err];
        if(err)
        {
            NSLog(@"error while creating path %@",path);
            return NULL;
        }
        return filename;
    }
    return NULL;
}

- (UMLicenseServerCommandError)insertMessage:(UMLicense *)msg
                      onCompletionCallObject:(id)obj
                                withSelector:(SEL)sel
{
    NSInteger seq = [self getSequenceNumber];
    
    UMLicenseSessionCompletionObject *co = [[UMLicenseSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;
    
    UMLicenseServerCommandInsertMessageRequest *req = [[UMLicenseServerCommandInsertMessageRequest alloc]init];
    req.sequenceNumber = seq;
    req.message = msg;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMLicenseServerCommandError_INVALID_STATE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}

- (BOOL) awaitsResponses
{
    if(_pendingSequences.count > 0)
    {
        return YES;
    }
    return NO;
}


- (UMLicenseServerCommandError) doLogin:(NSString *)username
                               password:(NSString *)password
                               instance:(NSString *)instance
                 onCompletionCallObject:(id)obj
                           withSelector:(SEL)sel
{
    if((obj) && (sel))
    {
        if(![obj respondsToSelector:sel])
        {
            UMAssert(0,@"Object does not respond to selector");
        }
    }
    NSInteger seq = [self getSequenceNumber];
    
    UMLicenseSessionCompletionObject *co = [[UMLicenseSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;
    
    UMLicenseServerCommandLoginRequest *req = [[UMLicenseServerCommandLoginRequest alloc]init];
    req.sequenceNumber = seq;
    req.username = username;
    req.password = password;
    req.instance = instance;
    req.apiVersion = 1;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMLicenseServerCommandError_INVALID_STATE;
    }
    return UMLicenseServerCommandError_NO_ERROR;
}

- (void)startHeartbeat
{
    [_handshakeTimer start];
}

- (void)stopHeartbeat
{
    [_handshakeTimer stop];
}

@end
