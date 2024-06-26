// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <dispatch/dispatch.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#include "util.h"

typedef struct {
  int32_t x;
  int32_t y;
} SomeStruct;

@protocol SuperProtocol<NSObject>

@required
- (NSString*)instanceMethod:(NSString*)s withDouble:(double)x;

@end

@protocol MyProtocol<SuperProtocol>

@optional
- (int32_t)optionalMethod:(SomeStruct)s;

@optional
- (void)voidMethod:(int32_t)x;

@end


@protocol SecondaryProtocol<NSObject>

@required
- (int32_t)otherMethod:(int32_t)a b:(int32_t)b c:(int32_t)c d:(int32_t)d;

@optional
- (nullable instancetype)returnsInstanceType;

@end

@protocol EmptyProtocol
@end


@interface ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<MyProtocol>)protocol;
- (int32_t)callOptionalMethod:(id<MyProtocol>)protocol;
- (int32_t)callOtherMethod:(id<SecondaryProtocol>)protocol;
- (void)callMethodOnRandomThread:(id<SecondaryProtocol>)protocol;
@end

@implementation ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<MyProtocol>)protocol {
  return [protocol instanceMethod:@"Hello from ObjC" withDouble:3.14];
}

- (int32_t)callOptionalMethod:(id<MyProtocol>)protocol {
  if ([protocol respondsToSelector:@selector(optionalMethod:)]) {
    SomeStruct s = {123, 456};
    return [protocol optionalMethod:s];
  } else {
    return -999;
  }
}

- (int32_t)callOtherMethod:(id<SecondaryProtocol>)protocol {
  return [protocol otherMethod:1 b:2 c:3 d:4];
}

- (void)callMethodOnRandomThread:(id<MyProtocol>)protocol {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    [protocol voidMethod:123];
  });
}
@end


@interface ObjCProtocolImpl : NSObject<MyProtocol, SecondaryProtocol>
@end

@implementation ObjCProtocolImpl
- (NSString *)instanceMethod:(NSString *)s withDouble:(double)x {
  return [NSString stringWithFormat:@"ObjCProtocolImpl: %@: %.2f", s, x];
}

- (int32_t)optionalMethod:(SomeStruct)s {
  return s.x + s.y;
}

- (int32_t)otherMethod:(int32_t)a b:(int32_t)b c:(int32_t)c d:(int32_t)d {
  return a + b + c + d;
}

@end


@interface ObjCProtocolImplMissingMethod : NSObject<MyProtocol>
@end

@implementation ObjCProtocolImplMissingMethod
- (NSString *)instanceMethod:(NSString *)s withDouble:(double)x {
  return @"ObjCProtocolImplMissingMethod";
}
@end
