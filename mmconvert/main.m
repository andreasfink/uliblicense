//
//  main.m
//  mmconvert
//
//  Created by Andreas Fink on 06.06.18.
//

#import <Foundation/Foundation.h>
#include "../version.h"
#import <uliblicense/uliblicense.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSDictionary *appDefinition = @
        {
            @"version" : @(VERSION),
            @"executable" : @"mmdisplay",
            @"run-as" : @(argv[0]),
            @"copyright" : @"© 2018 Andreas Fink",
        };
        
        NSArray *commandLineDefinition = @[
                                           @{
                                               @"name"  : @"version",
                                               @"short" : @"-V",
                                               @"long"  : @"--version",
                                               @"help"  : @"shows the software version"
                                               },
                                           @{
                                               @"name"  : @"verbose",
                                               @"short" : @"-v",
                                               @"long"  : @"--verbose",
                                               @"help"  : @"enables verbose mode"
                                               },
                                           @{
                                               @"name"  : @"help",
                                               @"short" : @"-h",
                                               @"long" : @"--help",
                                               @"help"  : @"shows the help screen",
                                               },
                                           @{
                                               @"name"  : @"file",
                                               @"short" : @"-f",
                                               @"long"  : @"--legacy-file",
                                               @"argument" : @"filename",
                                               @"help"  : @"display the license info from file",
                                               },
                                           @{
                                               @"name"  : @"key",
                                               @"short" : @"-k",
                                               @"long"  : @"--encryption-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"use indicated encryption key file",
                                               }];
        
        UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                                           appDefinition:appDefinition
                                                                                    argc:argc
                                                                                    argv:argv];
        [_commandLine handleStandardArguments];
        NSDictionary *params = _commandLine.params;
        
        UMLicenseDirectory *licdir = [[UMLicenseDirectory alloc]init];
        
        if(params[@"key"])
        {
            NSArray *filenames = params[@"key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    [licdir addKey:key];
                }
                else
                {
                    NSString *d = err.description;
                    fprintf(stderr,"Error: can not read keyfile %s\n%s\n",filename.UTF8String,d.UTF8String);
                }
            }
        }
        if(params[@"file"])
        {
            NSArray *filenames = params[@"file"];
            for(NSString *filename in filenames)
            {
                UMLicenseFile *lf = [[UMLicenseFile alloc]initWithFilename:filename];
                if(lf)
                {
                    [licdir addLicenseFile:lf];
                }
                else
                {
                    fprintf(stderr,"Error: can not read license file %s\n",filename.UTF8String);
                }
            }
        }
        [licdir decryptLicenses];
        [licdir validateSignatures];
        NSString *d = licdir.description;
        fprintf(stdout,"%s",d.UTF8String);
    }
    return 0;
}
