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


yms_u128_t yms_u128_genOffset(int value) {
    yms_u128_t offset = {0, 0};
    offset.lo = (unsigned long long)value;
    return offset;
}


yms_u128_t yms_u128_genBLEOffset(int value) {
    yms_u128_t offset = {0, 0};
    offset.hi = (unsigned long long)value << 32;
    return offset;
}


__uint16_t yms_u16_build(__uint16_t lo, __uint16_t hi) {
    __uint16_t result = ((lo & 0xff)| ((hi << 8) & 0xff00));
    return result;
}

