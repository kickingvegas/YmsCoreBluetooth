//
//  YMS128.h
//  Deanna
//
//  Created by Charles Choi on 1/16/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#ifndef Deanna_YMS128_h
#define Deanna_YMS128_h

typedef struct {
    unsigned long long hi;
    unsigned long long lo;
} yms_u128_t;


unsigned long long getfield64(unsigned long long s, int p, int n);
yms_u128_t yms_u128_genOffset(int value);
yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset);
yms_u128_t yms_u128_genAddressWithInt(yms_u128_t *base, int value);

#endif
