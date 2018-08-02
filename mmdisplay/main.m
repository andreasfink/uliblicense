//
//  main.m
//  mmdisplay
//
//  Created by Andreas Fink on 05.06.18.
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
                                               @"long"  : @"--file",
                                               @"argument" : @"filename",
                                               @"help"  : @"display the license info from file",
                                               },
                                           @{
                                               @"name"  : @"key",
                                               @"short" : @"-k",
                                               @"long"  : @"--decryption-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"decryption key file",
                                               },
                                           @{
                                               @"name"  : @"sigver",
                                               @"short" : @"-s",
                                               @"long"  : @"--signature-verification-key",
                                               @"argument" : @"keyfile",
                                               @"help"  : @"signature verification key file"
                                               }];
        
        UMCommandLine *_commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                                           appDefinition:appDefinition
                                                                                    argc:argc
                                                                                    argv:argv];
        [_commandLine handleStandardArguments];
        NSDictionary *params = _commandLine.params;
        
        UMLicenseDirectory *licdir = [[UMLicenseDirectory alloc]init];
        [licdir addDecryptionKey:decryptionKey];
        [licdir addSignatureVerificationKey:signatureVerificationKey];

        if(params[@"key"])
        {
            NSArray *filenames = params[@"key"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    [licdir addDecryptionKey:key];
                }
                else
                {
                    NSString *d = err.description;
                    fprintf(stderr,"Error: can not read keyfile %s\n%s\n",filename.UTF8String,d.UTF8String);
                }
            }
        }
        if(params[@"sigver"])
        {
            NSArray *filenames = params[@"sigver"];
            for(NSString *filename in filenames)
            {
                NSError *err =NULL;;
                
                NSString *key = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
                if(key)
                {
                    [licdir addSignatureVerificationKey:key];
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
        NSString *d = licdir.jsonString;
        fprintf(stdout,"%s",d.UTF8String);
    }
    return 0;
}
