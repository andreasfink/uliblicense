//
//  UMLicenseServerCommand.m
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <uliblicense/UMLicenseServerCommand.h>

@implementation UMLicenseServerCommand

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    [_asn1_tag setTagIsConstructed];
    _asn1_list = [[NSMutableArray alloc]init];

    UMASN1Integer *i0 = [[UMASN1Integer alloc]initWithValue:_command];
    i0.asn1_tag.tagNumber = 0;
    i0.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i0];

    UMASN1Integer *i1= [[UMASN1Integer alloc]initWithValue:_flags];
    i1.asn1_tag.tagNumber = 1;
    i1.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i1];

    UMASN1Integer *i2= [[UMASN1Integer alloc]initWithValue:_sequenceNumber];
    i2.asn1_tag.tagNumber = 2;
    i2.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i2];
}

- (UMLicenseServerCommand *) processAfterDecodeWithContext:(id)context
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
                case 0:
                {
                    UMASN1Integer *i =  [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _command = i.value;
                    break;
                }
                case 1:
                {
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _flags = i.value;
                    break;
                }
                case 2:
                {
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _sequenceNumber = i.value;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicenseServerCommand";
}


- (UMSynchronizedSortedDictionary *) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    dict[@"command"]                     = @(_command);
    dict[@"command-description"]         = self.objectName;
    dict[@"flags"]                       = @(_flags);
    dict[@"sequenceNumber"]              = @(_sequenceNumber);
    return dict;
}

@end
