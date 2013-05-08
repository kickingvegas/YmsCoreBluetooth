// 
// Copyright 2013 Yummy Melon Software LLC
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

#include <stdio.h>
#include "TISensorTag.h"

/**
 Generate offset for TI SensorTag address.
 
 @param value offset value
 @return offset in 128-bit struct form
 */
yms_u128_t yms_u128_genSensorTagOffset(int value) {
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
yms_u128_t yms_u128_genSensorTagAddressWithInt(yms_u128_t *base, int value) {
    
    yms_u128_t offset = yms_u128_genSensorTagOffset(value);
    
    yms_u128_t result = yms_u128_genAddress(base, &offset);
    
    return result;
}

