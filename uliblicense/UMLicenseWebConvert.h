//
//  UMLicenseWebConvert.h
//  mmconvert
//
//  Created by Andreas Fink on 02.08.18.
//

#import <ulib/ulib.h>

@interface UMLicenseWebConvert : UMObject<UMHTTPClientDelegateProtocol>
{
    NSString *_inputFilename;
    NSString *_outputFilename;
    NSString *_email;
    NSString *_signatureVerificationKey;
    NSString *_decryptionKey;

    NSInteger _status;
    BOOL _done;
    UMSleeper *_sleeper;
}

@property(readwrite,strong) NSString *inputFilename;
@property(readwrite,strong) NSString *outputFilename;
@property(readwrite,strong) NSString *email;
@property(readwrite,strong) NSString *signatureVerificationKey;
@property(readwrite,strong) NSString *decryptionKey;

@property(readwrite,assign) BOOL done;
@property(readwrite,assign) NSInteger status;

- (void)start;
- (void)waitUntilDone;
@end
