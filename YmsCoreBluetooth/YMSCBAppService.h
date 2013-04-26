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
@class YMSCBPeripheral;
@class YMSCBAppService;


/**
 Base class for defining a CoreBluetooth application service.

 Note that is not to be confused with a CoreBluetooth *service* where the term *service*
 has its own semantic definition with the context of the CoreBluetooth framework. Rather,
 an *application service* is meant here to define a set of functionality which is to be
 considered a sub-system of the application.
 
 YMSCBAppService is to be typically subclassed as a singleton instance.

 */
@interface YMSCBAppService : NSObject <CBCentralManagerDelegate>

/// Pointer to delegate.
@property (nonatomic, weak) id<CBCentralManagerDelegate> delegate;

/// Pointer to CBCentralManager. 
@property (nonatomic, strong) CBCentralManager *manager;

/// Array of YMSCBPeripheral instances.
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;

/**
 Array of NSStrings to search to match CBPeripheral instances.
 
 Used in conjunction with [isAppServicePeripheral:]
 */
@property (nonatomic, strong) NSArray *knownPeripheralNames;

/// Flag to determine if scanning.
@property (nonatomic, assign) BOOL isScanning;

/**
 Hold current manager state. This is a workaround for CoreBluetooth bug of raising alert
 if Bluetooth is turned off in Settings.
 */
@property (nonatomic, assign) CBCentralManagerState currentManagerState;

/// Count of ymsPeripherals.
@property (nonatomic, readonly, assign) NSUInteger count;

/**
 Constructor with array of known peripheral names.
 @param nameList Array of peripheral names of type NSString.
 @param queue The dispatch queue to use to dispatch the central role events. If its value is nil, the central manager dispatches central role events using the main queue.
 */
- (id)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue;

/**
 Determines if peripheral is known by this app service.
 Used in conjunction with knownPeripheralNames.
 
 @param peripheral found or retrieved peripheral
 @return YES is peripheral is to be managed by this app service.
 */

- (BOOL)isKnownPeripheral:(CBPeripheral *)peripheral;


/**
 Persist peripheral UUIDs.
 */
- (void)persistPeripherals;

/**
 Load peripheral UUIDs.
 */
- (void)loadPeripherals;


/**
 Handler for discovered or found peripheral. This method is to be overridden.

 @param peripheral CoreBluetooth peripheral instance
 */
- (void)handleFoundPeripheral:(CBPeripheral *)peripheral;

/**
 Start CoreBluetooth scan for peripherals. This method is to be overridden.
 
 The implementation of this method in a subclass must include the call to 
 scanForPeripheralsWithServices:options:
 
 */
- (void)startScan;

/**
 Returns the YSMCBPeripheral instance from ymsPeripherals at index.
 @param index An index within the bounds of ymsPeripherals.
 */
- (YMSCBPeripheral *)peripheralAtIndex:(NSUInteger)index;

/**
 Add YMSCBPeripheral instance to ymsPeripherals.
 @param yperipheral Instance of YMSCBPeripheral
 */
- (void)addPeripheral:(YMSCBPeripheral *)yperipheral;

/**
 Remove all occurrences of yperipheral in ymsPeripherals.
 @param yperipheral Instance of YMSCBPeripheral
 */
- (void)removePeripheral:(YMSCBPeripheral *)yperipheral;

/**
 Remove YMSCBPeripheral instance at index
 @param index The index from which to remove the object in ymsPeripherals. The value must not exceed the bounds of the array.
 */
- (void)removePeripheralAtIndex:(NSUInteger)index;



/**
 Wrapper around the method scanForPeripheralWithServices:options: in CBCentralManager.
 @param serviceUUIDs An array of CBUUIDs the app is interested in.
 @param options A dictionary to customize the scan, see CBCentralManagerScanOptionAllowDuplicatesKey.
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options;

/**
 Stop CoreBluetooth scan for peripherals.
 */
- (void)stopScan;

/**
 Connect peripheral.
 
 @param index index value of peripheral in ymsPeripherals.
 */
- (void)connectPeripheral:(NSUInteger)index;

/**
 Disconnect peripheral.
 
 @param index index value of peripheral in ymsPeripherals.
 */
- (void)disconnectPeripheral:(NSUInteger)index;

/**
 Find YMSCBPeripheral instance matching peripheral
 @param peripheral peripheral corresponding with YMSCBPeripheral
 @return instance of YMSCBPeripheral
 */
- (YMSCBPeripheral *)findPeripheral:(CBPeripheral *)peripheral;

@end

