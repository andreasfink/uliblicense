//
//  main.m
//  mmconvert
//
//  Created by Andreas Fink on 06.06.18.
//

#import <Foundation/Foundation.h>
#include "../version.h"
#import <uliblicense/uliblicense.h>

static NSString *decryptionKey =
@"-----BEGIN RSA PRIVATE KEY-----\n"
@"MIIJKQIBAAKCAgEAupJJTHXBDeMIdeYnezgD9/eHhapOFISNWeA1otheCdIJu42T\n"
@"OoTubh3X7527OTfv2FBr+9h8snqIDU7fsyKnY6Lb3t7GA6K5Q5hctHlGf659xRmC\n"
@"J2dTZqK/NJnr41nAxLst/odJm7kF4Z1k65iUFztxkv8Eodhkolr25AnlYIKntU9c\n"
@"3YxpKovJmOI6iypYlZvZSzUopIfOnRH+qpY2A2u0UVjSLhZgfjDFjA8r/hw0sUYF\n"
@"msi1Z3FeLBiG9NIcb4C6aju28eAN5qRkI8ED8Gm3W/ayXEvN5BDHQa0yJ+/Taghc\n"
@"mpkaxVebYJeYMJkBeH3MfKt47dRGHfkInDQWFXixfPOzfgdrvO2VkmpNXzTStpOT\n"
@"WnwVYnC5Folxgs02zofwiMQVF6kKePwHcF6mEkOaFUWslpKLjbNRZ5Nyo7OQ9K3F\n"
@"ww/YSumnMsR6pYr5yWav18MtYWae2rS+S7YulMpIP2LjQZLlmtj+BJdqFlC8zKtT\n"
@"lsnT++fltBfXnb3svzqmeyfWNyB6ksrYre5WP1V8myuYzXbl7atnKtg3YTq0yO0G\n"
@"uaXr6UcJ0YF4zIvs123OzTQ2wt0a5uvl/NxaX8xLA86tO87pZBJhBDvpqg05LTWS\n"
@"ihjfffWMtW3qHDkLoP3qNsTs/E5shVT9t1G9mIUKUkP5JO101V5JT9b7uWcCAwEA\n"
@"AQKCAgEAlMb0xpEcStuhsoq/LyZDG+j63B8rtnbhVStS+jH6A3DHrBVAs6ivjYYk\n"
@"3QJ1+zHdBC1VfvZqsdS+S4Z7IplezDhhhv80/k8z13BXdN9E1aqqxpMJ1Cw0OKNN\n"
@"QEAB+EFpVDhDfDYb/57yzrA5exon9cLEVckgw4MQ9Nr/CGfPzz9BR3crAcznTDM+\n"
@"pri4oKM7Esq945hXeaSGoYBpCVVRazbnCvt+V5wmhFqWHZM3rKKHbln9PCoTZpLj\n"
@"2twQOoiWfmAzx2UpBQZ7b1HmPRC8+GkE+8PlBW65l8W9b2USmwBHIcXbOrkevQGY\n"
@"eNVKWm6Y2qHOgBgpDdZ5t4sQT6fFdyodoyeu2L5QMKN3u5DEU/bixUtohBwzuZzd\n"
@"6+590fE4npsN6PWGqEVFFCXFCC4vDRM4zFdWZpYZ+1iLxftjLnMq59LMI49/YQyk\n"
@"4LYf36csFn5tx19zccBG7tTqrngNdfbpK/41iRte/A8WhCttJdgRjK0FnoA/jAHU\n"
@"t6i20qSibqJE2qTgypxRP0QruKbWMbDOKQ/RxPLVKZWcaFVdr+XJRz5zxmuzr2fB\n"
@"rxoldH9BhSzzeXmcYmSxNnTdiyrJoB0Wz4ot/y93JiM5MrVXywR/UsDhFjqBJ3Co\n"
@"8RvIZgB+od8ZIMZssO4LWbSSYl7nNVcV1ZQocNjdfjBtcAWyyEkCggEBAOz+ye5w\n"
@"5+k2FiVMzE5XrJ1XB9vnwu9hevlEi3VviPF+Vxu0w8Ds0cRKFdMF7HhfArGcSA5M\n"
@"7vsuL9GbokAy2eIRQxqCqKF+021rZyZOVPIHUBxpEB6c0N0saTiG/TnRxSxfh5cV\n"
@"2E/ZObzWp0dgB4pqEPh519+V6bBR/9FgO06RCDfFIA+sqNqp35Oy41xmaaW6fZVh\n"
@"VkrR84pIhqOPJm9ijxqUz5XqktnT0VzH4jCQx3ULyGx+eUgfhJ/X4cynuPQTeUpJ\n"
@"0jSXXWC6CH8qvr5f15k4ZJ02ItzIVOtQJK+ubCasawl2FOzacWWsNwWIOimJs+cM\n"
@"/9pb4cqTEudi0KUCggEBAMmIXD4CVLAmjzopnUmjgdYEwEwZsVx0E+cfnn+nO/fV\n"
@"zKw9UUOGfdgvZ5lVEuyxhzqw7oe/1Pzun9ZXDk/ZTEw4DGKJemTuEw+scHd8ou+a\n"
@"TDYyPI8SLrwppDM02HzDumtTmn3Q2m/kwhwJzQSioTHFBqmOgx6qdrUwt89SqebX\n"
@"hJy1yMDYOAUCR5u1cz8xO1wQOkC6oi7Q1NfaXxbPf+PXmM9b3KcsD8xKSnHH4Z6P\n"
@"2h2L2Eqpf7W8NlozslH3NOM0Y2XZOCt9jRoP3ECFwwa7UfSap3OpEm72xhdsxQYc\n"
@"X4NKg09vjyugh5aswqQ0/r9MasMnYdqDaj0I7+HLWBsCggEAF9/K49RH6HxkWrmT\n"
@"00iNwQPlbMe6IXdGdhnrmpbzyrAZglcBaUvyDb4Q2MM+ARpBITdHIvmpEXCjrI/r\n"
@"FmCJBncKtX74Edy+28T4DSnS8Na/wTzsPMk7WSyCJQmkNNDm9gNhm1y9/704Tcep\n"
@"7kzENbNdpkpP7twhQHviM2toTg/aLhQTmMCh+fUm6rAYq1Q9zE4vHH9DvCHOUN3h\n"
@"glSHYK0jEWBwUP/ib0MhUiForc/H6AiZ1iQff559M8UBoCY9QYk8rLknDdk5tObI\n"
@"uFbMBE2PYIYHzLaJaIhd1Z6rM290waiY18knbnzK850Xpd0FTu3qS5pJo+uhoVCT\n"
@"lO+laQKCAQEAq4BSVyauoRS/UBS32EG/rLxwVJKMv4u8oDPlMubC/p4/xdeMfzVF\n"
@"hKKau/6M00YkOUr2Qil6fCApf0KoWEUoS7hqubQapyd+qxjowJYdJl+dOYW4yVwE\n"
@"z3V0WWtAS7RYwRrtXuJL8Wqv0SJ6CNbI7Eyp5cL0TDVuPbUOxuymz15aaO29wHZ/\n"
@"/as5+wUH5R/lTuw0Vn88ozBt4J7hysycHe2MCfI3rT+u1f/mqDscAk6SpBAs6SSj\n"
@"HKnlaw+RUXVY2XzslXCr/z6hxCr5GSN7mw/vp4OwupmHqUxxuN+ELzYYBed0JTZf\n"
@"lRXQLOYp4YmDvJGwTREHkefBkd04HmNoPwKCAQBSkvp0k0tHOf5jG+K5Yvgca88P\n"
@"i4zty8cFRz38WK8QpWUHS1DqqQQpXjfUZ0g0q6W7DNNXVB4ZJmGgtBZdVgvOeMuz\n"
@"SaK4AhCdqU3aJynmcJ5vz9K4BURXRATREzfSUGzyPsITmma2gPx0ZbYPs8Ak+tOH\n"
@"IkxJnhx6kQz5zikYJvrb8U7o5itpCISsz9F2kB3Wu24q3bPF6Ox5qS+xzqnNSn8j\n"
@"MiMfEispLdp+Vbg/NVeTTsAPrgaKRLuVHqUSrYtSbZPH82N/Lxmxg0nx2FjRbrw7\n"
@"A5Rkh71Ul5EcXsQvHy7HW0gCIAcAhowvQz2zh7z+6RC45lfmFm7Db+OMANxL\n"
@"-----END RSA PRIVATE KEY-----\n";

static NSString *signatureVerificationKey =
@"-----BEGIN RSA PRIVATE KEY-----\n"
@"MIIJJwIBAAKCAgEAsxnayLqYwH+QbTMdJB1ju1glztLXnuoMhQkmojqLm0SllGgm\n"
@"xOWGDXyJa+XEdxv1ctnVRju23kPzSqVKK03UYMi1FE+6q4ZqYOxlSgIBg/HJBpz6\n"
@"dYKxHe4CHnMtaXbnjVvBARqYlIZtj+4b3sk30Jmge8J3N32Q/6ke96YdT04cbJAJ\n"
@"eaawKGEvbolj6oel/iXrcHyFSQ6vd2sioCaVTDGE5T7ComIchpk/O/sUuMG+4DoO\n"
@"+XfJ6lmOIFxk+A1Ic0PGB7McfslCveSN1u4QHBAY4Jxsp54n5EcclC9fZdTWueO0\n"
@"jjroGimRi5FkG8RfhGcdaCRDgF3Zr+3bJaDfqAwVDFf5TBnDZe/W5VgwRojTQdBn\n"
@"SHkTb0V6EfZ2s6u8dnf0LYM6ZytUzJ+0cbJEf5v5BW1nv+h0+qeP2HJMsScQeUR2\n"
@"6eAoe/lqqD66v7mTW+l6KXpy7tWyW5Bnq2vaXvD/eE/eRVAiEAd8zLdJdfVuD7Ez\n"
@"ZGOl7770Y1qihW59oIzBJB/2VH4zTGlZOiZEYKSFe9bvEa3uNMbH3o4AaEC7403Y\n"
@"zHpnrFLi0PE4szWXmSlLIrVhgdYb9Vhft8bkzSJ5s4jHmGCut+agwOz74GC8c4t9\n"
@"B7GHrT3OITrhqvM3DNaAOzg3YzCBU/hIVVkS0kmYzR/32O06hkdMGEk9fA8CAwEA\n"
@"AQKCAgAbHMHa+yxej7EMZt11dyF+3dQzYAWWH/YvOXhovJYfth+evLmJuvk1F3Iy\n"
@"LEE2irv4W/OGQ0nmkcDFvwngTlLlJ90JqxwmFR4LeB3JO06Ba9uzrZXYriUj08Ds\n"
@"XSE1wvNAmfA4u473hPYXAMOlUS6q3GbH9WNYuiB2I2L1uGbdd4SkBpX4nXwzUKr+\n"
@"f7vpaAl/1Lu0dpUyvw9e84/1UIHvW9uzXHHYZSPOWGqTKOo1IddEWGWl7DVbzZzP\n"
@"V01No60hDdRvm/SnWM5KssuqCrXTmbg6YFOueCmvy/gOkrFNWA/9afQOR+qU80/+\n"
@"Ic9WyL5w668u8bZqO0rV8BrpslXI+Lg60woJfXwUjrGom17GjcR1DLb0sI1HslZn\n"
@"/JecewbxL+NPuqLrccNG2GGJ9c2Yj16B6deOTalfH+4KnvEWTk0YSiI34+4A/I22\n"
@"qEJ8bv4Z74YR5uLgnl0qjWqHKq9Dm8cFahiK4+/dPOPaAliWi/HIpzOr/GJCxHLF\n"
@"4I/xjm1M+BZuwghoYQ7Re2cfsK948vscKBiiHdbeDxXL9orGBqNkec4bQvNuw4sn\n"
@"qyWdSq059DB2fGTol7XR7ka9WpXCJWXPrjRYS/MZZkIw8NT4EKSHg3edXUx3Knlu\n"
@"+eFQmbJJPbMi8QlVdez0eH9I7GtaDffP4KMgfhgMWnjHGtAXOQKCAQEA5T0BY4gw\n"
@"SY8AN3j3IPzn4oVRP29nhDYIi/0ED+yW9jXJcrsv3ZvP8AB+MbfdheA4orSaYwKX\n"
@"+dwXVFynjyrO7G6+Y++Duj8SBuOs0oGWX/LZL1T/xm4UKYUCWG9mZJUB8+oP+0sG\n"
@"rV8x91qxsPq5wxxClN4SJNKtgLxXfjY+ivt2Oq/3rXQqKHDYzWe16p9T9SABBFSO\n"
@"9xp0VregXZ/sJm51OtXlKJFB/fHIua0xf9C2rexOMX6zZBGWqsdDWKfmZtAOOUS5\n"
@"jfiZMuTtLC/fgJjgCECHlaMo4F7IOwLEJ9kKrXFGm48kYqgK3POxFlm5KAdQO0vZ\n"
@"cw0st3GqA3hqqwKCAQEAyAJzRdtHH99Lj5dctPwMWN3nc/2LjvdagN9H/Cxqnsgv\n"
@"sgtAHnfOM8AMLJb68PoVxEOwNjKuDgjh2K3SjH2VjkcKPmp/gmvav1cVsRcOhw3E\n"
@"GRPPzcBHw9hGfu2mM0FhwuEzjvhsAyu0NywRhhKkB8lIjoHGxi+UvtZRmaWv+m0M\n"
@"K/HGOeqVOnQ55/Iow2UDifQYF4FYquFg9vg+fWh+v/pqghuSArsYsGR5Gdz74j/W\n"
@"PXtnQ+8QR+sAagYUQFR3l4M4x3kAGjq+IoUrYeSFDYnVNZbYE5aT0rKvH+ldkblu\n"
@"31O7ZnzhzOIgRf2exaUJThv0j1airlAR/pL9pjg0LQKCAQB4c6m7JuBYhm9StpkE\n"
@"GF+vwuWCM4NtEQdEp1nvFB3umSyUwI7SHwEP1vJ4JWic48helg9ZXw+EFoWbqmPQ\n"
@"8mlwCnC4Ci5pOqK6Q/+XTMg6+lvsZvlOxqCJgH5PAZoH19QC2kYzgKStjIuwsVMU\n"
@"72mUf9DscBOQjbLlJhHDG7WZSbBB/hxiY9uTDFie9ZO9CKMQ9hQStmu4o4nl1u7I\n"
@"wzNOrlOi6qlSu6C1Uspp5ftQcdbLZJNhpnWUazmD2tgkSXTjKQeQR/BIDQxSlb+Z\n"
@"rD4AUFPHgkC7+9OKscL8XuO7HGxj3lV/f6Naw3mRx+qRF+wWgGFEBwLnVVDdwzfW\n"
@"QvupAoIBAEjoq8ChSHIT4eV8Fa1b29xhN8gOetsoy/MCcak5P7yV2N0cQMlafu5a\n"
@"aZWvi9ZgM6MR0aBQJSa0ki98Xa4c8XGl79QE2mpeiqUJR70AXKlamUtS74NfPknk\n"
@"Av6t/tHcWZjCoxrQ7/7P5affBpxLG0RDWZGpOR5xpdVTJvfNcDLnoXI7djkSjEd8\n"
@"qsckfTuNDRcyxb17xyizc7dTkuQAPYQZ8s1u43DfZwaV+Zc1+RPmlWBgJaqb8OFm\n"
@"hwYfJS62G8o9aWs9bo4hL8JBrSjINsBSqEgarrWlREmgHTqSxSsj34jFayDXETCw\n"
@"lXcuFryRhqzUf/foavED+ytDxfbbshkCggEAVs02Bf19BLjsdKIvzDxeWVAah6YP\n"
@"cgXcgxp40jzTRbzovqjOAXOlTBmTmKDeuafvrWS7KIFXIFqW5nNNSvzKOswOoMEq\n"
@"BiEw182V9ZDdLLYNQOpLbulF635HgOzCXarXbak5WMVnoQoETtWGZIQqJEbrn/NL\n"
@"QNEqQE17nBAEBSWT1Ff1OlBzs2o1qaErCyyHz2HhG+nHcPLh6ptTIb9+qa8yTLQd\n"
@"YN1Qq+wPThoajcvd6Jkaw1MQNBL/VSZ8eONf6SZ38MQOr91BcubgpyRksOklou24\n"
@"9pMtlL+dxhHFu1htzO3u2M8D3u9VQ3jgcKgKsPlJ83RiyV2yJ5r0zCEmAA==\n"
@"-----END RSA PRIVATE KEY-----\n";

int main(int argc, const char * argv[])
{
    NSString *email = @"dummy@example.com";
    @autoreleasepool
    {
        NSDictionary *appDefinition = @
        {
            @"version" : @(VERSION),
            @"executable" : @"mmconvert",
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
                                               @"name"  : @"input",
                                               @"short" : @"-i",
                                               @"long"  : @"--input-file",
                                               @"argument" : @"filename",
                                               @"help"  : @"input file to convert",
                                               },
                                           @{
                                               @"name"  : @"output",
                                               @"short" : @"-o",
                                               @"long"  : @"--output-file",
                                               @"argument" : @"filename",
                                               @"help"  : @"output file",
                                               },
                                           @{
                                               @"name"  : @"email",
                                               @"short" : @"-e",
                                               @"long"  : @"--email",
                                               @"argument" : @"email-address",
                                               @"help"  : @"email address of the owner of the license",
                                               },
                                           @{
                                               @"name"  : @"encryption-key",
                                               @"short" : @"-k",
                                               @"long"  : @"--encryption-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"use indicated encryption key file",
                                               },
                                           @{
                                               @"name"  : @"signature-key",
                                               @"short" : @"-s",
                                               @"long"  : @"--signature-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"use indicated signature key file",
                                            },
                                           @{
                                               @"name"  : @"web-convert",
                                               @"short" : @"-w",
                                               @"long"  : @"--web-convert",
                                               @"help"  : @"convert license file using online method",
                                               }];


        UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                                           appDefinition:appDefinition
                                                                                    argc:argc
                                                                                    argv:argv];
        [_commandLine handleStandardArguments];
        NSDictionary *params = _commandLine.params;
        
        UMLicenseDirectory *licdir = [[UMLicenseDirectory alloc]init];
        NSString *encryptionKey = NULL;
        NSString *signatureKey = NULL;
        NSString *outputLicenseFileName = NULL;
        BOOL webConvert = NO;
        if(params[@"encryption-key"])
        {
            NSArray *filenames = params[@"encryption-key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    encryptionKey = key;
                }
            }
        }
        if(params[@"email"])
        {
            NSArray *emails = params[@"email"];
            if(emails.count > 0)
            {
                email = emails[0];
            }
        }
        if(params[@"webConvert"])
        {
            webConvert=YES;
        }

        if(params[@"signature-key"])
        {
            NSArray *filenames = params[@"signature-key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    signatureKey = key;
                }
            }
        }
        if((encryptionKey==NULL) && (webConvert==NO))
        {
            fprintf(stderr,"encryption key is mandatory\n");
            exit(-1);
        }

        if((signatureKey==NULL)  && (webConvert==NO))
        {
            fprintf(stderr,"signature key is mandatory\n");
            exit(-1);
        }

        if(params[@"output"])
        {
            NSArray *filenames = params[@"output"];
            for(NSString *filename in filenames)
            {
                outputLicenseFileName = filename;
            }
        }

        if(webConvert)
        {
            NSArray *filenames = params[@"input"];
            for(NSString *filename in filenames)
            {
                UMLicenseWebConvert *webConvertor = [[UMLicenseWebConvert alloc]init];
                webConvertor.inputFilename = filename;
                webConvertor.outputFilename = [NSString stringWithFormat:@"%@-converted.license",filename];
                webConvertor.email = email;
                webConvertor.signatureVerificationKey =signatureVerificationKey;
                webConvertor.decryptionKey = decryptionKey;
                fprintf(stdout,"online converting '%s' to '%s'\n",filename.UTF8String,webConvertor.outputFilename.UTF8String);
                [webConvertor start];
                [webConvertor waitUntilDone];
            }
        }
        else if(params[@"input"])
        {
            NSArray *filenames = params[@"input"];
            for(NSString *filename in filenames)
            {
                UMLegacyLicense *ll  = [[UMLegacyLicense alloc]init];
                NSData *data = [NSData dataWithContentsOfFile:filename];
                if(data == NULL)
                {
                    fprintf(stderr,"Error: can not read license file %s\n",filename.UTF8String);
                    break;
                }
                ll.ciphertext = data;
                [ll decrypt];
                data = ll.plaintext;
                NSString *tmpfile = [NSString stringWithFormat:@"/tmp/.mm.%d.plist",getpid()];
                
                /* we dont want any trailing 0x00 bytes as this confuses GNUStep */
                size_t len = strnlen((void *)data.bytes, (size_t)data.length);
                data = [data subdataWithRange:NSMakeRange(0,len) ];
                
                [data writeToFile:tmpfile atomically:YES];
                NSDictionary *licDict = [NSDictionary dictionaryWithContentsOfFile:tmpfile];
                if(licDict == NULL)
                {
                    fprintf(stderr,"Error: can not read legacy license file %s\n",filename.UTF8String);
                }
                else
                {
                    NSLog(@"License read: %@",licDict);
                    
                    
                    NSString *licenseOwner      = licDict[@"license-name"];
                    NSString *licenseNumber     = licDict[@"license-number"];
                    NSDictionary *features      = licDict[@"features"];
                    
                    NSString *expiry            = licDict[@"expiry"];
                    NSString *hwSerial          = licDict[@"serial"];

                    BOOL featureEnabled_billing = NO;
                    BOOL featureEnabled_core = NO;
                    BOOL featureEnabled_emiucp = NO;
                    BOOL featureEnabled_gsmmap = NO;
                    BOOL featureEnabled_http = NO;
                    BOOL featureEnabled_httpHlr = NO;
                    BOOL featureEnabled_logging = NO;
                    BOOL featureEnabled_m2pa = NO;
                    BOOL featureEnabled_m3ua = NO;
                    BOOL featureEnabled_mofwd = NO;
                    BOOL featureEnabled_mtp3 = NO;
                    BOOL featureEnabled_quota = NO;
                    BOOL featureEnabled_rerouter = NO;
                    BOOL featureEnabled_sccp = NO;
                    BOOL featureEnabled_sctp = NO;
                    BOOL featureEnabled_smpp = NO;
                    BOOL featureEnabled_smsc = NO;
                    BOOL featureEnabled_smsproxy = NO;
                    BOOL featureEnabled_tcap = NO;
                    BOOL featureEnabled_udp = NO;
                    BOOL featureEnabled_isupfwd = NO;
                    BOOL featureEnabled_wappush = NO;

#define CHECK_FEATURE(featureName,featureVar) \
                    { \
                        NSDictionary *d = features[featureName]; \
                        if(d) \
                        { \
                            id var =  d[@"enable"]; \
                            if([var isKindOfClass:[NSNumber class]]) \
                            { \
                                featureVar =  [((NSNumber *)var) boolValue]; \
                            } \
                            else if([var isKindOfClass:[NSString class]]) \
                            { \
                                NSString *s = (NSString *)var; \
                                if([s isEqualToString:@"YES"] || [s isEqualToString:@"true"] || [s isEqualToString:@"1"]) \
                                { \
                                    featureVar =  YES; \
                                } \
                            }\
                        } \
                    }
                    
                    CHECK_FEATURE(@"billing",featureEnabled_billing);
                    CHECK_FEATURE(@"core",featureEnabled_core);
                    CHECK_FEATURE(@"emiucp",featureEnabled_emiucp);
                    CHECK_FEATURE(@"gsmmap",featureEnabled_gsmmap);
                    CHECK_FEATURE(@"http",featureEnabled_http);
                    CHECK_FEATURE(@"http-hlr",featureEnabled_httpHlr);
                    CHECK_FEATURE(@"logging",featureEnabled_logging);
                    CHECK_FEATURE(@"m2pa",featureEnabled_m2pa);
                    CHECK_FEATURE(@"m3ua",featureEnabled_m3ua);
                    CHECK_FEATURE(@"mofwd",featureEnabled_mofwd);
                    CHECK_FEATURE(@"mtp3",featureEnabled_mtp3);
                    CHECK_FEATURE(@"quota",featureEnabled_quota);
                    CHECK_FEATURE(@"rerouter",featureEnabled_rerouter);
                    CHECK_FEATURE(@"sccp",featureEnabled_sccp);
                    CHECK_FEATURE(@"sctp",featureEnabled_sctp);
                    CHECK_FEATURE(@"smpp",featureEnabled_smpp);
                    CHECK_FEATURE(@"smsc",featureEnabled_smsc);
                    CHECK_FEATURE(@"tcap",featureEnabled_tcap);
                    CHECK_FEATURE(@"udp",featureEnabled_udp);
                    CHECK_FEATURE(@"isupfwd",featureEnabled_isupfwd);
                    CHECK_FEATURE(@"wappush",featureEnabled_wappush);

                    CHECK_FEATURE(@"proxy",featureEnabled_smsproxy);
                    CHECK_FEATURE(@"smsproxy",featureEnabled_smsproxy);
#undef CHECK_FEATURE
                    

                    UMLicenseProduct *smsc          = [[UMLicenseProduct alloc]initWithName:@"smsc"];
                    UMLicenseProduct *smsproxy      = [[UMLicenseProduct alloc]initWithName:@"smsproxy"];

                    UMLicense *lic = [[UMLicense alloc]init];

                    UMSignedLicense *slicense       = [[UMSignedLicense alloc]init];
                    lic.licenseType                 = @"permanent";
                    slicense.license                = lic;

#define  CONDITIONAL_ADD_PRODUCT_ALL(name,flag) \
                    if (flag) \
                    { \
                        [smsc addFeatureWithName:name]; \
                        [smsproxy addFeatureWithName:name]; \
                    }
                    CONDITIONAL_ADD_PRODUCT_ALL(@"core",featureEnabled_core);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"sctp",featureEnabled_sctp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"m2pa",featureEnabled_m2pa);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"mtp3",featureEnabled_mtp3);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"m3ua",featureEnabled_m3ua);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"sccp",featureEnabled_sccp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"tcap",featureEnabled_tcap);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"gsmmap",featureEnabled_gsmmap);

                    CONDITIONAL_ADD_PRODUCT_ALL(@"http",featureEnabled_http);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"http-hlr",featureEnabled_httpHlr);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"mofwd",featureEnabled_mofwd);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"emiucp",featureEnabled_emiucp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"billing",featureEnabled_billing);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"logging",featureEnabled_logging);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"quota",featureEnabled_quota);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"smpp",featureEnabled_smpp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"udp",featureEnabled_udp);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"isupfwd",featureEnabled_isupfwd);
                    CONDITIONAL_ADD_PRODUCT_ALL(@"wappush",featureEnabled_wappush);

#undef CONDITIONAL_ADD_PRODUCT_ALL
                    
                    if(featureEnabled_smsc)
                    {
                        [smsc addFeatureWithName:@"smsc"];
                        [lic addProduct:smsc];
                    }
                    if(featureEnabled_smsproxy)
                    {
                        [smsc addFeatureWithName:@"smsproxy"];
                        [lic addProduct:smsproxy];
                    }

                    NSDate *expiration = [expiry dateValue];

                    if(expiration)
                    {
                        lic.licenseType = @"temporary";
                    }
                    else
                    {
                        lic.licenseType = @"permanent";
                    }
                
                    lic.licenseOwner = licenseOwner;
                    lic.licenseSerialNumber = licenseNumber;
                    lic.licenseExpiration =  expiration;
                    lic.licenseEmail = email;
                    UMLicenseRestriction *rest = [[UMLicenseRestriction alloc]init];
                    rest.lockedToLegacySerial = hwSerial;
                    [lic addRestriction: rest];
                    slicense.license = lic;
                    if(outputLicenseFileName==NULL)
                    {
                        outputLicenseFileName = [NSString stringWithFormat:@"%@.license",slicense.license.licenseSerialNumber];
                    }
                    if(signatureKey)
                    {
                        [slicense signLicenseWithRSAPublicKey:signatureKey];
                    }
                    if(encryptionKey)
                    {
                        [slicense encryptLicenseWithRSAPublicKey:encryptionKey];
                    }
                    NSData *data = [slicense berEncoded];
                    fprintf(stderr,"writing new license to %s",outputLicenseFileName.UTF8String);
                    [data writeToFile:outputLicenseFileName atomically:YES];
                }
            }
            [licdir decryptLicenses];
            [licdir validateSignatures];
            NSString *d = licdir.description;
            fprintf(stdout,"%s",d.UTF8String);
        }
    }
    return 0;
}
