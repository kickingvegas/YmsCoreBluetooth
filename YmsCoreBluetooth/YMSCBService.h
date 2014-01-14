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

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "YMSCBUtils.h"

/**
 Callback type for discovered characteristics.
 */
typedef void (^YMSCBDiscoverCharacteristicsCallbackBlockType)(NSDictionary *, NSError *);

typedef NS_ENUM(NSInteger, YMSCBCallbackTransactionType) {
    YMSCBWriteCallbackType,
    YMSCBReadCallbackType,
};


@class YMSCBCharacteristic;
@class YMSCBPeripheral;

/**
 Base class for defining a Bluetooth LE service.

 YMSCBService holds an instance of CBService (cbService).
 
 This class is typically subclassed to map to a service in a BLE peripheral. The subclass
 typically implements notifyCharacteristicHandler:error: to handle characteristics whose
 BLE notification has been enabled. 
 */

@interface YMSCBService : NSObject

/** @name Properties */
/// Human-friendly name for this BLE service
@property (atomic, strong) NSString *name;

/**
 Pointer to CBService. Note that access to the peripheral is available via the `peripheral` property of cbService.
 */
@property (atomic, strong) CBService *cbService;

/// Pointer to parent peripheral.
@property (nonatomic, weak) YMSCBPeripheral *parent;

/// 128 bit base address struct
@property (atomic, assign) yms_u128_t base;

/// Service UUID
@property (atomic, strong) CBUUID *uuid;

/**
 When set to YES, the CoreBluetooth service is turned on.
*/
@property (atomic, assign) BOOL isOn;

/** CoreBluetooth characteristics are synchronized */
@property (atomic, assign) BOOL isEnabled;

/// Dictionary of (`key`, `value`) pairs of (NSString, YMSCBCharacteristic) instances
@property (atomic, strong) NSMutableDictionary *characteristicDict;

/// Callback for characteristics that are discovered.
@property (atomic, copy) YMSCBDiscoverCharacteristicsCallbackBlockType discoverCharacteristicsCallback;


/**
 Initialize class instance.
 @param oName name of service
 @param pObj parent object which owns this service
 @param hi top 64 bits of 128-bit base address value
 @param lo bottom 64 bits of 128-bit base address value
 @param serviceOffset offset address of service
 @return YMSCBCharacteristic
 */
- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset;


/**
 Initialize class instance.
 
 @param oName name of service
 @param pObj parent object which owns this service
 @param hi top 64 bits of 128-bit base address value
 @param lo bottom 64 bits of 128-bit base address value
 @param serviceOffset BLE offset address of service
 @return YMSCBCharacteristic
 */
- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
            serviceBLEOffset:(int)serviceOffset;

/** @name Adding a BLE characteristic */
/**
 Add YMSCBCharacteristic instance given address offset.
 @param cname Characteristic name
 @param addrOffset Offset value
 */
- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset;

/**
 Add YMSCBCharacteristic instance given BLE address offset
 
 @param cname      Characteristic name
 @param addrOffset BLE offset value
 */
- (void)addCharacteristic:(NSString *)cname withBLEOffset:(int)addrOffset;

/**
 Add YMSCBCharacteristic instance given absolute address.
 
 @param cname Characteristic name
 @param addr Absolute address value
 */
- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr;

/** @name Retrieve CBUUIDs for all discovered characteristics */
/**
 Return array of CBUUIDs for all YMSCBCharacteristic instances in characteristicDict.
 
 @return array of CBUUIDs
 */
- (NSArray *)characteristics;

/**
 Return array of CBUUIDs for YMSCBCharacteristic instances in characteristicDict whose key is included in keys.
 
 @param keys array of NSString keys, where each key must exist in characteristicDict.
 
 @return array of CBUUIDs
 */
- (NSArray *)characteristicsSubset:(NSArray *)keys;

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


/**
 Discover characteristics for this service.
 
 @param characteristicUUIDs An array of CBUUID objects that you are interested in. Here, each CBUUID object represents a UUID that identifies the type of a characteristic you want to discover.
 @param callback Callback block to execute upon response for discovered characteristics.
 
 */
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs
                      withBlock:(void (^)(NSDictionary *chDict, NSError *))callback;
/**
 Handler method for discovered characteristics.
 
 @param chDict Dictionary of YMSCBCharacteristics that have been discovered.
 @param error Error object, if failure.
 */
- (void)handleDiscoveredCharacteristicsResponse:(NSDictionary *)chDict withError:(NSError *)error;

/**
 Add dictionary style subscripting to YMSCBService instance to access objects in characteristicDict with key.
 
 @param key The key for which to return the corresponding value in characteristicDict.
 @return object in characteristicDict.
 */
- (id)objectForKeyedSubscript:(id)key;

//- (void)defaultDiscoveredCharacteristicsHandler:(NSDictionary *)chDict withError:(NSError *)error;

@end
