//
//  YMS128.h
//  Deanna
//
//  Created by Charles Choi on 1/16/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#ifndef Deanna_YMS128_h
#define Deanna_YMS128_h


/**
 Struct to hold 128-bit value
 */
typedef struct {
    __uint64_t hi;
    __uint64_t lo;
} yms_u128_t;



__uint64_t getfield64(__uint64_t s, int p, int n);
yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset);


#endif
