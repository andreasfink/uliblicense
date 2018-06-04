//
//  UMLicenseRestriction.h
//  uliblicense
//
//  Created by Andreas Fink on 31.05.18.
//

#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>

@interface UMLicenseRestriction : UMASN1Choice
{
    NSString *_lockedToCpuId;
    NSString *_lockedToMacAddress;
    NSString *_lockedToUUID;
    NSString *_lockedToIp;
    NSString *_lockedToSerial;
    NSString *_lockedToOperatingSystem;
}

@property(readwrite,strong,atomic)  NSString *lockedToCpuId;
@property(readwrite,strong,atomic)  NSString *lockedToMacAddress;
@property(readwrite,strong,atomic)  NSString *lockedToUUID;
@property(readwrite,strong,atomic)  NSString *lockedToIp;
@property(readwrite,strong,atomic)  NSString *lockedToSerial;
@property(readwrite,strong,atomic)  NSString *lockedToOperatingSystem;

@end
