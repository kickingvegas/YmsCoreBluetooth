// 
// Copyright 2013-2014 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//

#import "YMSCBUtils.h"




@implementation YMSCBUtils


+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset {
    NSString *result;
    
    yms_u128_t address = yms_u128_genAddress(base, offset);
    
    result = [NSString stringWithFormat:@"%08llx-%04llx-%04llx-%04llx-%012llx" ,
              getfield64(address.hi, 32, 32),
              getfield64(address.hi, 16, 16),
              getfield64(address.hi, 0, 16),
              getfield64(address.lo, 48, 16),
              getfield64(address.lo, 0, 48)
              ];

    return result;
}


+ (CBUUID *)createCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset {
    CBUUID *result;
    
    NSString *uuidString = [YMSCBUtils genCBUUID:base withOffset:offset];
    
    result = [CBUUID UUIDWithString:uuidString];
    return result;
}



+ (NSString *)genCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset {
    NSString *result;
    
    yms_u128_t offset = yms_u128_genOffset(addrOffset);
    
    result = [YMSCBUtils genCBUUID:base withOffset:&offset];
    
    return result;
    
}


+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset {
    CBUUID *result;
    
    NSString *uuidString = [YMSCBUtils genCBUUID:base withIntOffset:addrOffset];
    
    result = [CBUUID UUIDWithString:uuidString];
    return result;
}



+ (NSString *)genCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset {
    NSString *result;
    
    yms_u128_t offset = yms_u128_genBLEOffset(addrOffset);
    
    result = [YMSCBUtils genCBUUID:base withOffset:&offset];
    
    return result;
}

+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset {
    CBUUID *result;
    
    NSString *uuidString = [YMSCBUtils genCBUUID:base withIntBLEOffset:addrOffset];
    
    result = [CBUUID UUIDWithString:uuidString];
    return result;
}



+ (int8_t)dataToByte:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int8_t result = val[0];
    return result;
}

+ (int16_t)dataToInt16:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int16_t result = (val[0] & 0x00FF) | (val[1] << 8 & 0xFF00);
    return result;
}

+ (int32_t)dataToInt32:(NSData *)data {
    char val[data.length];
    [data getBytes:&val length:data.length];
    int32_t result = ((val[0] & 0x00FF) |
                      (val[1] << 8 & 0xFF00) |
                      (val[2] << 16 & 0xFF0000) |
                      (val[3] << 24 & 0xFF000000));
    
    return result;
}





@end
