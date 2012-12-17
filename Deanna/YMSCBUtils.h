//
//  YMSCBUtils.h
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    unsigned long long hi;
    unsigned long long lo;
} yms_u128_t;


unsigned long long getfield64(unsigned long long s, int p, int n);


@interface YMSCBUtils : NSObject

+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

@end
