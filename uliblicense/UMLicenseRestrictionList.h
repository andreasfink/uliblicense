//
//  UMLicenseRestrictionList.h
//  uliblicense
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulibasn1/ulibasn1.h>

@interface UMLicenseRestrictionList : UMASN1Sequence
{
    NSMutableArray *_sequenceEntries;
}
@end
