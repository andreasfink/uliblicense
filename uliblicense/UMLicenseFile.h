//
//  UMLicenseFile.h
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import <ulib/ulib.h>

@class UMLicense;
@class UMSignedLicense;
@interface UMLicenseFile : UMObject
{
    UMSignedLicense *_signedLicense;
    NSString *_fullPath;
    NSString *_shortName;
    NSDate *_lastRefresh;
    NSDate *_nextUpdate;
    NSDate *_nextReport;
    BOOL    _debug;
}

@property(readwrite,strong) UMSignedLicense *signedLicense;
@property(readwrite,strong) NSString *fullPath;
@property(readwrite,strong) NSString *shortName;
@property(readwrite,strong) NSDate *lastRefresh;
@property(readwrite,strong) NSDate *nextUpdate;
@property(readwrite,strong) NSDate *nextReport;
@property(readwrite,assign) BOOL debug;

- (UMLicenseFile *)initWithFilename:(NSString *)filename debug:(BOOL)dbg;
- (UMLicenseFile *)initWithFilename:(NSString *)filename;
- (void)updateData:(NSData *)data;
- (void)updateTimeIntervals;

@end

