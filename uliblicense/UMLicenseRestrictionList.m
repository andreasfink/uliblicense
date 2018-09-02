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
    _asn1_tag.isConstructed=YES;
    _asn1_list = [[NSMutableArray alloc]init];
    for(id entry in _sequenceEntries)
    {
        [_asn1_list addObject:entry];
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
        UMLicenseRestriction *r = [[UMLicenseRestriction alloc]initWithASN1Object:o context:context];
        [_sequenceEntries addObject:r];
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
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for(UMLicenseRestriction *p in _sequenceEntries)
    {
        [arr addObject:p.objectValue];
    }
    return arr;
}

- (NSUInteger)count
{
   return [_sequenceEntries count];
}
- (UMLicenseRestriction *)objectAtIndex:(unsigned)index
{
	return [_sequenceEntries objectAtIndex:index];
}

@end
