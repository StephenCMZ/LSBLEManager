//
//  EncoderUtil.h
//  STBLEDemo
//
//  Created by StephenChen on 15/6/2.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncoderUtil : NSObject

+ (NSData *) hexToByteArray: (NSString *) input;
+ (NSString *)getHexByData:(NSData *)data;
+ (NSString *)getBinaryByhex:(NSString *)hex;
+ (NSString *)getHexByBinary:(NSString *)binary;
+ (NSString *)getStringFromHex:(NSString *)str;
+ (int)getIntFromBinary:(NSString *)binary;
+ (NSString *)intToHex:(long long int)tmpid;

+ (UInt16)getBytesCRC16:(const char*)bytes length:(int)length;
