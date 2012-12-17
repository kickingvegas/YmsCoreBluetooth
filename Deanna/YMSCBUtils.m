//
//  YMSCBUtils.m
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBUtils.h"


unsigned long long getfield64(unsigned long long s, int p, int n) {
    unsigned long long d = s;
    
    d = s << (64 - (p+n));
    d = d >> (64 - n);
    
    return d;
}

@implementation YMSCBUtils


+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset {
    NSString *result;
    
    
    yms_u128_t tempVal;
    
    tempVal.hi = (*base).hi | (*offset).hi;
    tempVal.lo = (*base).lo | (*offset).lo;
    
    result = [NSString stringWithFormat:@"%08llx-%04llx-%04llx-%04llx-%012llx" ,
              getfield64(tempVal.hi, 32, 32),
              getfield64(tempVal.hi, 16, 16),
              getfield64(tempVal.hi, 0, 16),
              getfield64(tempVal.lo, 48, 16),
              getfield64(tempVal.lo, 0, 48)
              ];

    return result;
}


@end
