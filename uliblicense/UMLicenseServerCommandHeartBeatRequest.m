//
//  UMLicenseServerCommandHeartBeatRequest.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommandHeartBeatRequest.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>

@implementation UMLicenseServerCommandHeartBeatRequest

- (UMLicenseServerCommandHeartBeatRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMLicenseServerCommand_HEARTBEAT_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMLicenseServerCommand_HEARTBEAT_REQUEST;
    
    [super processBeforeEncode];
}


- (NSString *) objectName
{
    return @"UMLicenseServerCommandHeartbeatRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    return dict;
}

- (UMLicenseServerCommandHeartBeatRequest *) processAfterDecodeWithContext:(id)context
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
