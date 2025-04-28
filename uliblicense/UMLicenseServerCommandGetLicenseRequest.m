//
//  UMLicenseServerCommandGetLicenseRequest.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import "UMLicenseServerCommandGetLicenseRequest.h"

@implementation UMLicenseServerCommandGetLicenseRequest

- (UMLicenseServerCommandGetLicenseRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMLicenseServerCommand_GET_LICENSE_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMLicenseServerCommand_GET_LICENSE_REQUEST;

    [super processBeforeEncode];
    if(_application)
    {
        UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_application];
        s.asn1_tag.tagNumber = 3;
        s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
    if(_instance)
    {
        UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_instance];
        s.asn1_tag.tagNumber = 4;
        s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
    if(_serial)
    {
        UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_serial];
        s.asn1_tag.tagNumber = 5;
        s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
    if(_macaddresses)
    {
        UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_macaddresses];
        s.asn1_tag.tagNumber = 6;
        s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
    if(_ipaddresses)
    {
        UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_ipaddresses];
        s.asn1_tag.tagNumber = 7;
        s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
}

- (NSString *) objectName
{
    return @"UMLicenseerverCommandGetMessageRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    
    if(_application)
    {
        dict[@"application"] = _application;
    }
    if(_instance)
    {
        dict[@"instance"] = _instance;
    }
    if(_serial)
    {
        dict[@"serial"] = _serial;
    }
    if(_macaddresses)
    {
        dict[@"macaddresses"] = _macaddresses;
    }
    if(_ipaddresses)
    {
        dict[@"ipaddresses"] = _ipaddresses;
    }
    return dict;
}

- (UMLicenseServerCommandGetLicenseRequest *) processAfterDecodeWithContext:(id)context
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
                case 3:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _application = s.stringValue;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _instance = s.stringValue;
                    break;
                }
                case 5:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _serial = s.stringValue;
                    break;
                }
                case 6:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _macaddresses = s.stringValue;
                    break;
                }
                case 7:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _ipaddresses = s.stringValue;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
