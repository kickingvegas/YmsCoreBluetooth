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
#import "YMSCBUtils.h"

typedef void (^YMSCBDiscoverCharacteristicsCallbackBlockType)(NSDictionary *, NSError *);

typedef NS_ENUM(NSInteger, YMSCBCallbackTransactionType) {
    YMSCBWriteCallbackType,
    YMSCBReadCallbackType,
};


@class YMSCBCharacteristic;
@class YMSCBPeripheral;

/**
 Base class for defining a Bluetooth LE service.

 YMSCBService holds an instance of CBService (cbService) and provides a service-centric
 read/write API to a CBPeripheral instance contained in YMSCBPeripheral.
 
 This class is typically subclassed to map to a service in a BLE peripheral. The subclass
 typically implements notifyCharacteristicHandler:error: to handle characteristics whose
 BLE notification has been enabled. 
 


 */

@interface YMSCBService : NSObject

/** @name Properties */
/// Human-friendly name for this BLE service
@property (nonatomic, strong) NSString *name;

/**
 Pointer to CBService. Note that access to the peripheral is available via the `peripheral` property of cbService.
 */
@property (nonatomic, strong) CBService *cbService;

/// Pointer to parent peripheral.
@property (nonatomic, weak) YMSCBPeripheral *parent;

/// 128 bit base address struct
@property (nonatomic, assign) yms_u128_t base;

/**
 When set to YES, the CoreBluetooth service is turned on.
*/
@property (nonatomic, assign) BOOL isOn;

/** CoreBluetooth characteristics are synchronized */
@property (nonatomic, assign) BOOL isEnabled;

/// Holds (key, value pairs of (NSString, YMSCBCharacteristic) instances
@property (nonatomic, strong) NSMutableDictionary *characteristicDict;

/// Callback for characteristics that are discovered.
@property (nonatomic, strong) YMSCBDiscoverCharacteristicsCallbackBlockType discoverCharacteristicsCallback;


/** @name Initializing a YMSCBService */
/**
 Initialize class instance.
 @param oName name of service
 @param hi top 64 bits of 128-bit base address value
 @param lo bottom 64 bits of 128-bit base address value
 @return YMSCBCharacteristic
 */
- (id)initWithName:(NSString *)oName
            parent:(YMSCBPeripheral *)pObj
            baseHi:(int64_t)hi
            baseLo:(int64_t)lo;

/** @name Adding a BLE characteristic */
/**
 Add YMSCBCharacteristic instance given address offset.
 @param cname characteristic name
 @param addrOffset offset value
 */
- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset;

/**
 Add YMSCBCharacteristic instance given address offset.
 @param cname characteristic name
 @param addr offset value
 */
- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr;

/** @name Retrieve CBUUIDs for all discovered characteristics */
/**
 Return array of CBUUIDs for all YMSCBCharacteristic instances in characteristicDict.
 */
- (NSArray *)characteristics;

/** @name Synchronize found CBCharacteristic instances with corresponding their YMSCBCharacter instance */
/**
 Synchronize found CBCharacteristics with corresponding YMSCBCharacteristic containers.
 
 @param foundCharacteristics array of CBCharacteristics
 */
- (void)syncCharacteristics:(NSArray *)foundCharacteristics;

/** @name Find a YMSCBCharacteristic */
/**
 Find characteristic container for CBCharacteristic.
 
 @param ct CBCharacteristic 
 @return container of ct
 */
- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct;

/**
 Method to handle response update for a prior read or write request to a characteristic.  
 
 This method is invoked by the CBPeripheralDelegate method peripheral:didUpdateValueForCharacteristic:error: 
 conformed to by YMSCBPeripheral.
 
 This method is typically overridden to handle characteristics whose notification has been turned on.
 
 @param yc Characteristic receiving update.
 @param error Error object.
 */
- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error;



- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs
                      withBlock:(void (^)(NSDictionary *chDict, NSError *))callback;

- (void)handleDiscoveredCharacteristicsResponse:(NSDictionary *)chDict withError:(NSError *)error;

//- (void)defaultDiscoveredCharacteristicsHandler:(NSDictionary *)chDict withError:(NSError *)error;



@end
