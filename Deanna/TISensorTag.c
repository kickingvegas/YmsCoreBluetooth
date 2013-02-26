//
//  TISensorTag.c
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#include <stdio.h>
#include "TISensorTag.h"

/**
 Generate offset for TI SensorTag address.
 
 @param value offset value
 @return offset in 128-bit struct form
 */
yms_u128_t yms_u128_genOffset(int value) {
    yms_u128_t offset = {0, 0};
    offset.hi = (unsigned long long)value << 32;
    return offset;
}

/**
 Generate TI SensorTag address with integer offset
 
 @param base base address
 @param value offset value
 @return address in 128-bit struct form
 */
yms_u128_t yms_u128_genAddressWithInt(yms_u128_t *base, int value) {
    
    yms_u128_t offset = yms_u128_genOffset(value);
    
    yms_u128_t result = yms_u128_genAddress(base, &offset);
    
    return result;
}

