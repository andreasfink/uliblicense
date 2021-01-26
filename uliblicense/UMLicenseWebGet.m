//
//  UMLicenseWebGet.m
//  uliblicense
//
//  Created by Andreas Fink on 02.08.18.
//

#import "UMLicenseWebGet.h"

@implementation UMLicenseWebGet

- (void)start
{
    NSData *data = [NSData dataWithContentsOfFile:_inputFilename];
    NSString *input = [data urlencode];
    NSString *url = [NSString stringWithFormat:@"https://license.messagemover.com/get.php?input=%@",input];
    UMHTTPClient *webClient = [[UMHTTPClient alloc]init];
    UMHTTPClientRequest *req = [[UMHTTPClientRequest alloc]init];
    req.urlString = url;
    req.delegate=self;
    req.reference=req;
    [webClient startRequest:req];
}

- (void) urlLoadCompletedForReference:(id)ref
                                 data:(NSData *)data
                               status:(NSInteger)statusCode
{
    _status = statusCode;
    UMHTTPClientRequest *req = (UMHTTPClientRequest *)ref;
    req.reference = NULL;

    if(_outputFilename==NULL)
    {
        _outputFilename = @"converted.license";
    }
    fprintf(stderr,"writing new license to %s",_outputFilename.UTF8String);
    [data writeToFile:_outputFilename atomically:YES];
    self.done=YES;
    [_sleeper wakeUp];
}

- (void)waitUntilDone
{
    _sleeper = [[UMSleeper alloc]initFromFile:__FILE__ line:__LINE__ function:__func__];
    while(self.done==NO)
    {
        [_sleeper sleep:1000000];
    }
}

@end
