//
//  UMLicenseCommandHandlerProtocol.h
//  mmlic
//
//  Created by Andreas Fink on 28.04.2025.
//


#import <ulib/ulib.h>

@class UMLicenseServerCommand;

@protocol UMLicenseCommandHandlerProtocol
- (void) processCommand:(UMLicenseServerCommand *)md;
@end
