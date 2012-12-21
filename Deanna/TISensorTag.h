//
//  TISensorTag.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#ifndef Deanna_TISensorTag_h
#define Deanna_TISensorTag_h

#define kSensorTag_IDENTIFIER "9C4EEB7D-BE3A-E942-1539-CB7AD105CE5D"

#define kSensorTag_BASE_ADDRESS_HI 0xF000000004514000
#define kSensorTag_BASE_ADDRESS_LO 0xB000000000000000

#define kSensorTag_GAP_SERVICE_UUID        0x1800
#define kSensorTag_GATT_SERVICE_UUID       0x1801

#define kSensorTag_TEMPERATURE_SERVICE     0xAA00
#define kSensorTag_TEMPERATURE_DATA        0xAA01
#define kSensorTag_TEMPERATURE_CONFIG      0xAA02

#define kSensorTag_ACCELEROMETER_SERVICE   0xAA10
#define kSensorTag_ACCELEROMETER_DATA      0xAA11
#define kSensorTag_ACCELEROMETER_CONFIG    0xAA12
#define kSensorTag_ACCELEROMETER_PERIOD    0xAA13

#define kSensorTag_HUMIDITY_SERVICE        0xAA20
#define kSensorTag_HUMIDITY_DATA           0xAA21
#define kSensorTag_HUMIDITY_CONFIG         0xAA22

#define kSensorTag_MAGNETOMETER_SERVICE    0xAA30
#define kSensorTag_MAGNETOMETER_DATA       0xAA31
#define kSensorTag_MAGNETOMETER_CONFIG     0xAA32
#define kSensorTag_MAGNETOMETER_PERIOD     0xAA33


#define kSensorTag_BAROMETER_SERVICE       0xAA40
#define kSensorTag_BAROMETER_DATA          0xAA41
#define kSensorTag_BAROMETER_CONFIG        0xAA42
#define kSensorTag_BAROMETER_CALIBRATION   0xAA43


#define kSensorTag_GYROSCOPE_SERVICE       0xAA50
#define kSensorTag_GYROSCOPE_DATA          0xAA51
#define kSensorTag_GYROSCOPE_CONFIG        0xAA52

typedef struct {
    unsigned long long hi;
    unsigned long long lo;
} yms_u128_t;


unsigned long long getfield64(unsigned long long s, int p, int n);
yms_u128_t yms_u128_genOffset(int value);
yms_u128_t yms_u128_genAddress(yms_u128_t *base, yms_u128_t *offset);
yms_u128_t yms_u128_genAddressWithInt(yms_u128_t *base, int value);



#endif
