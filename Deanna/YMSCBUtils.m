//
//  YMSCBUtils.m
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
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


+ (CBUUID *)createCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset {
    CBUUID *result;
    
    NSString *uuidString = [YMSCBUtils genCBUUID:base withOffset:offset];
    
    result = [CBUUID UUIDWithString:uuidString];
    return result;
}


@end
