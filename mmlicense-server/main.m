//
//  main.m
//  mmlicense-server
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <Foundation/Foundation.h>
#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>
#include <stdlib.h>
#include <uliblicense/uliblicense.h>

int main(int argc, const char * argv[])
{
    NSInteger port = 9129;
    const char *rootDirectory = "/opt/uliblicense";
    @autoreleasepool
    {
        if(argc>1)
        {
            rootDirectory = argv[1];
        }
        if(argc>2)
        {
            port = atol(argv[2]);
        }
        if((port<1) || (port > 65535))
        {
            fprintf(stderr,"port %d is out of range (1...65535)\n",(int)port);
            return -1;
        }
        UMLicenseServer *ls =  [[UMLicenseServer alloc]initWithPort:port];
        ls.rootDirectory = @(rootDirectory);
        [ls startBackgroundTask];
        sleep(1); /* wait until listener is listening */
        while(ls.listener.isListening)
        {
            sleep(1);
        }
    }
    return 0;
}

