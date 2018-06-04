//
//  UMLicenseRestrictionList.m
//  uliblicense
//
//  Created by Andreas Fink on 31.05.18.
//

#import "UMLicenseRestrictionList.h"
#import "UMLicenseRestriction.h"

@implementation UMLicenseRestrictionList

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    asn1_tag.isConstructed=YES;
    asn1_list = [[NSMutableArray alloc]init];
    for(id entry in _sequenceEntries)
    {
        [asn1_list addObject:entry];
    }
}

- (void)addRestriction:(UMLicenseRestriction *)rest
{
    if(_sequenceEntries ==NULL)
    {
        _sequenceEntries = [[NSMutableArray alloc]init];
    }
    [_sequenceEntries addObject:rest];
}

- (UMLicenseRestrictionList *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    _sequenceEntries = [[NSMutableArray alloc]init];
    while(o)
    {
        [_sequenceEntries addObject:o];
        o = [self getObjectAtPosition:p++];
    }
    return self;
}

- (NSString *) objectName
{
    return @"UMLicenseRestrictionList";
}

- (id) objectValue
{
    return [_sequenceEntries copy];
}

@end
