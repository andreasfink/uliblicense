//
//  UMLicenseServerCommandHeartBeatRequest.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import "UMLicenseServerCommandHeartBeatRequest.h"

@implementation UMLicenseServerCommandHeartBeatRequest

@end
//
//  UMMessageServerCommandHeartbeatRequest.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommandHeartbeatRequest.h>
#import <um/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandHeartbeatRequest

- (UMMessageServerCommandHeartbeatRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_HEARTBEAT_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_HEARTBEAT_REQUEST;
    
    [super processBeforeEncode];
}


- (NSString *) objectName
{
    return @"UMMessageServerCommandHeartbeatRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    return dict;
}

- (UMMessageServerCommandHeartbeatRequest *) processAfterDecodeWithContext:(id)context
{
    [super processAfterDecodeWithContext:context];
    int pos = 0;
    UMASN1Object *o = [self getObjectAtPosition:pos++];
    while(o)
    {
        if(o.asn1_tag.tagClass==UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
                default:
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
