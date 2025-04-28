//
//  UMLicenseSessionCompletionObject.h
//  uliblicense
//
//  Created by Andreas Fink on 28.04.2025.
//

#import <ulib/ulib.h>


@interface UMLicenseSessionCompletionObject : UMObject
{
    id          _objectToCall;
    SEL         _selectorToCall;
    id          _data;
    int         _status;
    NSString    *_error;
}

@property(readwrite,strong,atomic)  id          objectToCall;
@property(readwrite,assign,atomic)  SEL         selectorToCall;
@property(readwrite,strong,atomic)  id          data;
@property(readwrite,assign,atomic)  int         status;
@property(readwrite,strong,atomic)  NSString    *error;

@end

