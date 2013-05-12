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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#include "YMSCBUtils.h"


NS_ENUM(NSInteger, YMSCBPeripheralConnectionState) {
    YMSCBPeripheralConnectionStateUnknown,
    YMSCBPeripheralConnectionStateDisconnected,
    YMSCBPeripheralConnectionStateConnecting,
    YMSCBPeripheralConnectionStateConnected
};

@class YMSCBAppService;
@class YMSCBService;

/**
 Base class for defining a Bluetooth LE peripheral.
 
 YMSCBPeripheral holds an instance of CBPeripheral (cbPeripheral) and implements
 the CBPeripheralDelegate messages sent by cbPeripheral.
 
 How those CBPeripheralDelegate messages are processed is where YmsCoreBluetooth 
 distinguishes itself from CoreBluetooth.
 
 In CoreBluetooth, read and write requests are issued via CBPeripheral. However, if 
 the BLE peripheral has many services, then the application would likely prefer to use
 an abstraction that issues read and write requests from the BLE service.

 **YmsCoreBluetooth offers this abstraction**. YMSCBPeripheral and YMSCBService are designed
 to provide a read/write API that is BLE service-centric.
 
 The BLE services discovered by cbPeripheral are encapulated in instances of YMSCBService and
 contained in the dictionary serviceDict.
 
 */
@interface YMSCBPeripheral : NSObject <CBPeripheralDelegate>

/** @name Properties */
/// 128 bit address base
@property (nonatomic, assign) yms_u128_t base;

/** 
 Dictionary of (`key`, `value`) pairs of (NSString, YMSCBService) instances.
 
 The NSString `key` is typically a "human-readable" string to easily reference a YMSCBService.
 */
@property (nonatomic, strong) NSDictionary *serviceDict;

/// The CBPeripheral instance.
@property (nonatomic, strong) CBPeripheral *cbPeripheral;

/**
 A Boolean value indicating whether the peripheral is currently connected to the central manager. (read-only)
 
 This value is populated with cbPeripheral.isConnected.
 */
@property (readonly) BOOL isConnected;


/**
 If set to YES, enable updates of RSSI are done via updateRSSI.
 */
@property (nonatomic, assign) BOOL willPingRSSI;

/**
 Time period between RSSI pings. (Default: 2 seconds)
 
 This property is used by updateRSSI to determine the period between requests for the RSSI.
 This property is only used when willPingRSSI is set to YES.
 */
@property (nonatomic, assign) NSTimeInterval rssiPingPeriod;


/**
 Parent owner of an instance of this class.
 */
@property (nonatomic, weak) YMSCBAppService *parent;


/** @name Initializing a YMSCBPeripheral */
/**
 Constructor.
 
 This method must be called via super in any subclass implementation.
 
 The implementation of this method in a subclass will populate serviceDict with (`key`, `value`) pairs of
 (NSString, YMSCBService) instances, where `key` is typically a "human-readable" string to easily 
 reference a YMSCBService.
 

 @param peripheral Pointer to CBPeripheral
 @param parent Parent of this instance
 @param hi Top 64 bits of 128-bit base address value
 @param lo Bottom 64 bits of 128-bit base address value
 @param update If YES, update the RSSI.
 @return instance of this class
 */
- (id)initWithPeripheral:(CBPeripheral *)peripheral
                  parent:(YMSCBAppService *)owner
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update;



/** @name Get all CBService CBUUIDs for this peripheral  */
/**
 Generate array of CBUUID for all SensorTag CoreBluetooth services.
 
 The output of this method is to be passed to the method discoverServices: in CBPeripheral:
 
 @return array of CBUUID services
 */
- (NSArray *)services;

/** @name Find a YMSCBService */
/**
 Find YMSCBService given its corresponding CBService.
 
 @param service CBService to search for in serviceDict.
 @return YMSCBService instance which holds *service*.
 */
- (YMSCBService *)findService:(CBService *)service;

/** @name Update the RSSI */
/**
 Request RSSI update from CBPeripheral.
 
 This method uses rssiPingPeriod for the frequency of updates.
 */
- (void)updateRSSI;

/**
 Discover the services 
 */
- (void)discoverServices;

/**
 Connect peripheral
 */
- (void)connect;

/**
 Disconnect peripheral
 */
- (void)disconnect;

@end

