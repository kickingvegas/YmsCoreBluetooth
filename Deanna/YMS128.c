//
//  YMS128.c
//  Deanna
//
//  Created by Charles Choi on 1/16/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#include <stdio.h>
#include "YMS128.h"

__uint64_t getfield64(__uint64_t s, int p, int n) {
    __uint64_t d = s;
    
    d = s << (64 - (p+n));
    d = d >> (64 - n);
    
    return d;
}


yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset) {
    yms_u128_t result;
    
    result.hi = (*base).hi | (*offset).hi;
    result.lo = (*base).lo | (*offset).lo;
    
    return result;
}

