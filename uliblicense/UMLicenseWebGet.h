//
//  UMLicenseWebGet.h
//  uliblicense
//
//  Created by Andreas Fink on 02.08.18.
//

#import <ulib/ulib.h>



@interface UMLicenseWebGet : UMObject<UMHTTPClientDelegateProtocol>
{
    NSString *_inputFilename;
    NSString *_outputFilename;
    NSInteger _status;
    BOOL _done;
    UMSleeper *_sleeper;
}

@property(readwrite,strong) NSString *inputFilename;
@property(readwrite,strong) NSString *outputFilename;
@property(readwrite,assign) BOOL done;
@property(readwrite,assign) NSInteger status;

- (void)start;
- (void)waitUntilDone;
@end
