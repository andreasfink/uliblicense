#include <Foundation/Foundation.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>

NSData *decryptData(NSData *data, NSData *key);

#define RXPIPE	0
#define TXPIPE	1



NSData *encryptData(NSData *data, NSData *keyData)
{
    
    size_t output_size = (([data length]*4+1023) / 1024) * 1024;
    unsigned char *output_ptr =  (unsigned char *)malloc(output_size);
    
    size_t input_size = (([data length]+1023) / 1024) * 1024;
    unsigned char *input_ptr =  (unsigned char *)malloc(input_size);
    
    size_t key_size = [keyData length];
    const unsigned char *key =  (const unsigned char *)[keyData bytes];
    
    memset(input_ptr,0x00,input_size);
    memcpy(input_ptr,[data bytes],[data length]);
    
    /* we pad to the next 1k with zero's */
    size_t new_output_size = 0;
    
    int j = 0;
    for(int i=0;i<input_size;i++)
    {
        output_ptr[i] = input_ptr[i] ^ key[j];
        j = j+1;
        j = j % key_size;
        new_output_size++;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    return result;
    
}

NSData *decryptData(NSData *data, NSData *keyData)
{
    
    size_t output_size = (([data length]*4+1023) / 1024) * 1024;
    unsigned char *output_ptr =  (unsigned char *)malloc(output_size);
    
    size_t input_size = (([data length]+1023) / 1024) * 1024;
    unsigned char *input_ptr =  (unsigned char *)malloc(input_size);
    
    size_t key_size = [keyData length];
    const unsigned char *key =  (const unsigned char *)[keyData bytes];
    
    memset(input_ptr,0x00,input_size);
    memcpy(input_ptr,[data bytes],[data length]);
    
    /* we pad to the next 1k with zero's */
    size_t new_output_size = 0;
    
    int j = 0;
    int i;
    for(i=0;i<input_size;i++)
    {
        output_ptr[i] = input_ptr[i] ^ key[j];
        j = j+1;
        j = j % key_size;
        new_output_size++;
    }
    NSData *result = [NSData dataWithBytes:output_ptr length:new_output_size];
    return result;
    
}

@implementation NSString(hex)
+ (int)nibbleToInt:(char)c
{
	switch(c)
	{
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			return c - '0';
		case 'A':
		case 'a':
			return 0x0A;
		case 'B':
		case 'b':
			return 0x0B;
		case 'C':
		case 'c':
			return 0x0C;
		case 'D':
		case 'd':
			return 0x0D;
		case 'E':
		case 'e':
			return 0x0E;
		case 'F':
		case 'f':
			return 0x0F;
	}
	return -1;
}
@end

@implementation NSData (HexFunctions)
- (NSString *) hexString
{
	NSMutableString *result;
	ssize_t i;
	ssize_t n;
	result = [[NSMutableString alloc]init];
	n = [self length];
	for(i=0;i<n;i++)
	{
		[result appendFormat:@"%02X",((unsigned char *)[self bytes])[i]];
	}
	[result autorelease];
	return result;
	
}

- (NSString *) gsmHexString
{
	NSMutableString *result;
	ssize_t i;
	ssize_t n;
	result = [[NSMutableString alloc]init];
	n = [self length];
	for(i=0;i<n;i++)
	{
		[result appendFormat:@"%02X",((unsigned char *)[self bytes])[i]];
	}
	[result autorelease];
	return result;
}

+ (NSData *) unhexFromString:(NSString *)str
{
	NSMutableData *result;
	ssize_t i;
	ssize_t n;
	int a;
	int b;
	unichar c;
	result = [[NSMutableData alloc]init];
	n = [str length];
	for(i=0;i<n;)
	{
		do
		{
			a = [NSString nibbleToInt:[str characterAtIndex: i++]];
		}
		while(a==-1);
		
		do
		{
			b = [NSString nibbleToInt:[str characterAtIndex: i++]];
		} while(b==-1);
		c = (a <4) | b;
		[result appendBytes:&c length:1];
	}
	[result autorelease];
	return result;	
}


- (NSData *) unhex
{
	NSMutableData *r = nil;
	NSData *result = nil;
	ssize_t i;
	ssize_t n;
	int a;
	int b;
	int c;
	const unsigned char *src;
	char *dst;
	
	n = [self length];
	r = [[NSMutableData alloc]initWithCapacity: n];
	src = [self bytes];
	dst = [r mutableBytes];
	for(i=0;i<n;)
	{
		do
		{
			a = [NSString nibbleToInt:src[i++]];
		}
		while(a==-1);
		
		do
		{
			b = [NSString nibbleToInt:src[i++]];
		} while(b==-1);
		c = (a <<4) | b;
		[r appendBytes:&c length:1];
	}
	result = [NSData dataWithData: r];
	[r release];
	return result;	
}

- (NSData *) hex
{
	NSMutableData *r;
	NSData *result;
	ssize_t i;
	ssize_t n;
	const unsigned char *src;
	char *dst;

	r = [[NSMutableData alloc]initWithCapacity: 2 *[self length]];
	n = [self length];

	src = [self bytes];
	dst = [r mutableBytes];
	for(i=0;i<n;i++)
	{
		snprintf(&dst[i*2],2,"%02X",src[i]);
	}		
	result = [NSData dataWithData: r];
	[r release];
	return result;	
}
	
@end

int main(int argc,const char **argv)
{
	if(argc!=2)
	{
		fprintf(stderr,"Usage: %s <file>\n",argv[0]);
		exit(-1);
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

	const unsigned char key1[] = {0xb8,0x77,0x36,0xe6,0x81,0xf8,0x1d,0x2f,0x04,0x88,0xd6,0x21,0x92,0x4b,0x58,0x54,0x04,0x69,0x3b,0x61,0x62,0x90,0x23,0x53,0x42,0x09,0x38,0x93,0x11,0xe7,0x5c,0xf8,0x55,0xc2,0xf1,0xb1,0xe5,0xe5,0x51,0x4c,0x94,0x5e,0x55,0xcc,0xf2,0x0d,0x43,0x28,0xf4,0xc4,0x20,0x11,0xf3,0x25,0x9a,0xca,0x46,0x2c,0x15,0x9e,0x81,0x1a,0x08,0xbc,0x7b,0x6a,0x4d,0x9e,0xbd,0x8f,0xa7,0xf5,0x22,0xfd,0xc1,0x14,0x0a,0x05,0x3c,0xfe,0xc9,0x5d,0x10,0xbd,0x82,0xaa,0x87,0xc8,0xd6,0x9c,0x66,0x57,0xb6,0x6e,0x14,0x31,0xd8,0x61,0xd0,0x95,0xf0,0x77,0x8a,0x12,0x74,0x4c,0x27,0x7f,0x51,0x63,0x7d,0x1a,0xc0,0x8d,0xd7,0x42,0x37,0x5e,0x0a,0x0e,0xfb,0x71,0x65,0xb1,0xdf,0x79,0xe3,0xb8};

	NSString *filename = [NSString stringWithFormat:@"%s",argv[1]];
	NSData *fileData = [NSData dataWithContentsOfFile:filename];
	
	int i=0;
	int n = [fileData length];
	const unsigned char *pin = [fileData bytes];
	unsigned char *pout = malloc(n);
	int j = 0;
	for(i=0;i<n;i++)
	{
		switch(pin[0])
		{
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		case 'a':
		case 'b':
		case 'c':
		case 'd':
		case 'e':
		case 'f':
		case 'A':
		case 'B':
		case 'C':
		case 'D':
		case 'E':
		case 'F':
			pout[j++]=pin[i];
			break;
		default:
			break;
		}
	}
	pout[j++]='\0';

	NSData *fileData2 = [[NSData alloc] initWithBytes:pout length:j];
	NSData *chipertext = [fileData2 unhex];
	NSData *key = [NSData dataWithBytes:key1 length:sizeof(key1)];
    NSData *plainData = decryptData(chipertext,key);
	NSString *plainText = [[NSString alloc] initWithBytes:[plainData bytes] length:[plainData length] encoding:NSUTF8StringEncoding];
	printf("%s\n",[plainText UTF8String]);
}
