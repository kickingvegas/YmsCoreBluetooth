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

#ifndef YMSCB_YMS128_h
#define YMSCB_YMS128_h


/**
 Struct to hold 128-bit value
 */
typedef struct {
    __uint64_t hi;
    __uint64_t lo;
} yms_u128_t;


/**
 Extract field from 64-bit word s.

 Code derived from original routine published in "The MIPS Programmer's Handbook" by Erin Farquhar and Philip Bunce.

 @param s 64-bit word
 @param p start position of field to extract
 @param n length of field to extract
 */
__uint64_t getfield64(__uint64_t s, int p, int n);

/**
 Generate 128-bit address given base and offset.

 @param base 128-bit struct
 @param offset 128-bit struct
 */
yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset);

/**
 Generate 128-bit offset.
 
 @param value value to offset
 */
yms_u128_t yms_u128_genOffset(int value);

/**
 Generate 128-bit BLE offset.
 
 This is written to comply with the Bluetooth Specification Version 4.0 [Vol. 3] Section 3.2.1 where:
 
     128-Bit UUID = 16-bit Attribute UUID * pow(2,96) + Bluetooth_Base_UUID

 @param value value to offset
 */
yms_u128_t yms_u128_genBLEOffset(int value);

/**
 Build 16-bit number given lo and hi byte values.

 @param lo low byte
 @param hi high byte
 */
__uint16_t yms_u16_build(__uint16_t lo, __uint16_t hi);

#endif
