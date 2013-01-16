//
//  TISensorTag.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#include "YMS128.h"

#ifndef Deanna_TISensorTag_h
#define Deanna_TISensorTag_h

// Is this unique?
#define kSensorTag_IDENTIFIER "9C4EEB7D-BE3A-E942-1539-CB7AD105CE5D"

#define kSensorTag_BASE_ADDRESS_HI 0xF000000004514000
#define kSensorTag_BASE_ADDRESS_LO 0xB000000000000000

#define kSensorTag_GAP_SERVICE_UUID        0x1800
#define kSensorTag_GATT_SERVICE_UUID       0x1801
#define kSensorTag_DEVINFO_SERV_UUID       0x180A


#define kSensorTag_SIMPLEKEYS_SERVICE      0xFFE0
#define kSensorTag_SIMPLEKEYS_DATA         0xFFE1

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

#define kSensorTag_TEST_SERVICE            0xAA60
#define kSensorTag_TEST_DATA               0xAA61
#define kSensorTag_TEST_CONFIG             0xAA62


#endif
