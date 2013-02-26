//
//  YMS128.c
//  Deanna
//
//  Created by Charles Choi on 1/16/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#include <stdio.h>
#include "YMS128.h"

unsigned long long getfield64(unsigned long long s, int p, int n) {
    unsigned long long d = s;
    
    d = s << (64 - (p+n));
    d = d >> (64 - n);
    
    return d;
}

/**
 This code is SensorTag specific.
 */
yms_u128_t yms_u128_genOffset(int value) {
    yms_u128_t offset = {0, 0};
    offset.hi = (unsigned long long)value << 32;
    return offset;
}


yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset) {
    yms_u128_t result;
    
    result.hi = (*base).hi | (*offset).hi;
    result.lo = (*base).lo | (*offset).lo;
    
    return result;
}


yms_u128_t yms_u128_genAddressWithInt(yms_u128_t *base, int value) {
    
    yms_u128_t offset = yms_u128_genOffset(value);
    
    yms_u128_t result = yms_u128_genAddress(base, &offset);
    
    return result;
}