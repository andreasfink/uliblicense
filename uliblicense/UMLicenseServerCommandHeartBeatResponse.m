//
//  UMLicenseServerCommandHeartBeatResponse.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommandHeartBeatResponse.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>

@implementation UMLicenseServerCommandHeartBeatResponse

- (UMLicenseServerCommandHeartBeatResponse *)init
{
    self = [super init];
    if(self)
    {
        _command = UMLicenseServerCommand_HEARTBEAT_RESPONSE;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMLicenseServerCommand_HEARTBEAT_RESPONSE;
    
    [super processBeforeEncode];
}

- (NSString *) objectName
{
    return @"UMLicenseServerCommandHeartBeatResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    return dict;
}

- (UMLicenseServerCommandHeartBeatResponse *) processAfterDecodeWithContext:(id)context
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
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
