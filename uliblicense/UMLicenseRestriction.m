//
//  UMLicenseRestriction.m
//  uliblicense
//
//  Created by Andreas Fink on 31.05.18.
//

#import "UMLicenseRestriction.h"

@implementation UMLicenseRestriction

- (void) processBeforeEncode
{
    [super processBeforeEncode];

    int count = 0;
    if(_lockedToCpuId)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToCpuId];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 0;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(_lockedToMacAddress)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToMacAddress];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 1;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(_lockedToUUID)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToUUID];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 2;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(_lockedToIp)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToIp];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 3;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(_lockedToSerial)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToSerial];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 4;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(_lockedToOperatingSystem)
    {
        UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithValue:_lockedToOperatingSystem];
        [utf8 processBeforeEncode];
        self.asn1_tag.tagNumber = 5;
        self.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        self.asn1_data = [utf8.asn1_data copy];
        count++;
    }
    if(count<1)
    {
        @throw([NSException exceptionWithName:@"PARAMETER_MISSING"
                                       reason:@"UMLicenseRestriction choice missing"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
    if(count>1)
    {
        @throw([NSException exceptionWithName:@"PARAMETER_ERROR"
                                       reason:@"UMLicenseRestriction more than one choice selected"
                                     userInfo:@{    @"backtrace": UMBacktrace(NULL,0)}]);
    }
}


- (UMLicenseRestriction *) processAfterDecodeWithContext:(id)context
{

    UMASN1UTF8String *utf8 = [[UMASN1UTF8String alloc]initWithASN1Object:self context:NULL];

    if(self.asn1_tag.tagClass == UMASN1Class_ContextSpecific)
    {
        switch (self.asn1_tag.tagNumber)
        {
        case 0:
            _lockedToCpuId = utf8.value;
            break;
        case 1:
            _lockedToMacAddress = utf8.value;
            break;
        case 2:
            _lockedToUUID = utf8.value;
            break;
        case 3:
            _lockedToIp = utf8.value;
            break;
        case 4:
            _lockedToSerial = utf8.value;
            break;
        case 5:
            _lockedToOperatingSystem = utf8.value;
            break;
        default:
            break;
        }
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicenseRestriction";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];

    if(_lockedToCpuId)
    {
        dict[@"lockedToCpuId"] = _lockedToCpuId;
    }
    if(_lockedToMacAddress)
    {
        dict[@"lockedToMacAddress"] = _lockedToMacAddress;
    }
    if(_lockedToUUID)
    {
        dict[@"lockedToUUID"] = _lockedToUUID;
    }
    if(_lockedToIp)
    {
        dict[@"lockedToIp"] = _lockedToIp;
    }
    if(_lockedToSerial)
    {
        dict[@"lockedToSerial"] = _lockedToSerial;
    }
    if(_lockedToOperatingSystem)
    {
        dict[@"lockedToOperatingSystem"] = _lockedToOperatingSystem;
    }

    return dict;
}


@end

