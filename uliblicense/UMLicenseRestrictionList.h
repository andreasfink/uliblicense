//
//  UMLicenseRestrictionList.h
//  uliblicense
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulib/ulib.h>

@class UMLicenseRestriction;

@interface UMLicenseRestrictionList : UMASN1Sequence
{
    NSMutableArray *_sequenceEntries;
}

- (void)addRestriction:(UMLicenseRestriction *)rest;
- (NSUInteger)count;
- (UMLicenseRestriction *)objectAtIndex:(unsigned)index;

@end
