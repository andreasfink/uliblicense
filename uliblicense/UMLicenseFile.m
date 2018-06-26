//
//  UMLicenseFile.m
//  uliblicense
//
//  Created by Andreas Fink on 05.06.18.
//

#import "UMLicenseFile.h"
#import "UMSignedLicense.h"
#import "UMLicense.h"
#import "UMEncryptedLicense.h"

@implementation UMLicenseFile


- (UMLicenseFile *)initWithFilename:(NSString *)filename
{
    self = [super init];
    if(self)
    {
        _lastRefresh =[NSDate date];
        _fullPath = filename;
        _shortName = [filename lastPathComponent];
        NSData *d = [NSData dataWithContentsOfFile:_fullPath];
        if(d==NULL)
        {
            return NULL;
        }
        NSUInteger i=0;
        UMASN1Object *o = [[UMASN1Object alloc]initWithBerData:d atPosition:&i context:NULL];
        UMSignedLicense *slic = [[UMSignedLicense alloc]initWithASN1Object:o context:NULL];
        if(slic == NULL)
        {
            return NULL;
        }
        _signedLicense = slic;
        [self updateTimeIntervals];
    }
    return self;
}

- (void)updateTimeIntervals
{
    if(_signedLicense.license)
    {
        int min = 30*60;
        int max = 45*60;
        if(_signedLicense.license.licenseRenewTimerMin!=NULL)
        {
            min = [_signedLicense.license.licenseRenewTimerMin intValue];
            if(min < 300)
            {
                min = 300;
                _signedLicense.license.licenseRenewTimerMin = @(min);
            }
        }
        if(_signedLicense.license.licenseRenewTimerMax!=NULL)
        {
            max = [_signedLicense.license.licenseRenewTimerMax intValue];
            if(max > (30*24*60*60))
            {
                max = (30*24*60*60); /* at least once a month */
                _signedLicense.license.licenseRenewTimerMax = @(max);
            }
        }
    }
}

- (void)updateData:(NSData *)data
{
    NSUInteger i=0;
    UMASN1Object *o = [[UMASN1Object alloc]initWithBerData:data atPosition:&i context:NULL];
    UMSignedLicense *slic = [[UMSignedLicense alloc]initWithASN1Object:o context:NULL];
    if(slic == NULL)
    {
        return;
    }
    _signedLicense = slic;
    [data writeToFile:_fullPath atomically:YES];
}

@end
