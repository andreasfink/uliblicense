//
//  UMLicenseRefreshDelegateProtocol.h
//  uliblicense
//
//  Created by Andreas Fink on 06.06.18.
//

#import <ulib/ulib.h>

@protocol UMLicenseRefreshDelegateProtocol<NSObject>

- (void)licenseUpdateRequestForAddress:(NSString *)addr serial:(NSString *)serial;
- (void)licenseReportRequestForAddress:(NSString *)addr serial:(NSString *)serial data:(NSData *)data;

@end
