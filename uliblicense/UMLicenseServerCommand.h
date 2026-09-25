//
//  UMLicenseServerCommand.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>
#import <uliblicense/UMLicenseServerCommandTypes.h>

@interface UMLicenseServerCommand : UMASN1Sequence
{
    NSInteger       _command;
    NSInteger       _flags;
    NSInteger       _sequenceNumber;
}

@property(readwrite,atomic,assign)  NSInteger       command;
@property(readwrite,atomic,assign)  NSInteger       flags;
@property(readwrite,atomic,assign)  NSInteger       sequenceNumber;

- (UMLicenseServerCommand *) processAfterDecodeWithContext:(id)context;
- (NSString *) objectName;
- (UMSynchronizedSortedDictionary *) objectValue;

@end

