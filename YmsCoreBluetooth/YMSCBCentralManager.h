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

// iOS7
#define kYMSCBVersionNumber 1090
#define kYMSCBVersion "1.090"
extern NSString *const YMSCBVersion;

@class YMSCBPeripheral;
@class YMSCBCentralManager;

typedef void (^YMSCBDiscoverCallbackBlockType)(CBPeripheral *, NSDictionary *, NSNumber *, NSError *);
typedef void (^YMSCBRetrieveCallbackBlockType)(CBPeripheral *);

/**
 Base class for defining a Bluetooth LE central.
 
 YMSCBCentralManager holds an instance of CBCentralManager (manager) and implements the
 CBCentralManagerDelgate messages sent by manager.
 
 This class provides ObjectiveC block-based callback support for peripheral
 scanning and retrieval.
 
 YMSCBCentralManager is intended to be subclassed: the subclass would in turn be written to 
 handle the set of BLE peripherals of interest to the application.
 
 The subclass is typically implemented (though not necessarily) as a singleton, so that there 
 is only one instance of CBCentralManager that is used by the application.

 All discovered BLE peripherals are stored in the array ymsPeripherals.

 Legacy Note: This class was previously named YMSCBAppService.
 */
@interface YMSCBCentralManager : NSObject <CBCentralManagerDelegate>

/** @name Properties */
/**
 Pointer to delegate.
 
 The delegate object will be sent CBCentralManagerDelegate messages received by manager.
 */
@property (nonatomic, weak) id<CBCentralManagerDelegate> delegate;

/**
 The CBCentralManager object.
 
 In typical practice, there is only one instance of CBCentralManager and it is located in a singleton instance of YMSCBCentralManager.
 This class listens to CBCentralManagerDelegate messages sent by manager, which in turn forwards those messages to delegate.
 */
@property (atomic, strong) CBCentralManager *manager;

/**
 Array of NSStrings to search to match CBPeripheral instances.
 
 Used in conjunction with isKnownPeripheral:.  
 This value is typically initialized using initWithKnownPeripheralNames:queue:.
 */
@property (atomic, strong) NSArray *knownPeripheralNames;

/// Flag to determine if manager is scanning.
@property (atomic, assign) BOOL isScanning;

/**
 Array of YMSCBPeripheral instances.
 
 This array holds all YMSCBPeripheral instances discovered or retrieved by manager.
 */
@property (atomic, readonly, strong) NSArray *ymsPeripherals;

/// Count of ymsPeripherals.
@property (atomic, readonly, assign) NSUInteger count;

/// API version.
@property (atomic, readonly, assign) NSString *version;


/// Peripheral Discovered Callback
@property (atomic, copy) YMSCBDiscoverCallbackBlockType discoveredCallback;

/// Peripheral Retreived Callback
@property (atomic, copy) YMSCBRetrieveCallbackBlockType retrievedCallback;

/// If YES, then discovered peripheral UUIDs are stored in standardUserDefaults.
@property (atomic, assign) BOOL useStoredPeripherals;

#pragma mark - Constructors
/** @name Initializing YMSCBCentralManager */
/**
 Constructor with array of known peripheral names.
 
 By default, this constructor will not use stored peripherals from standardUserDefaults.
 
 @param nameList Array of peripheral names of type NSString.
 @param queue The dispatch queue to use to dispatch the central role events. 
 If its value is nil, the central manager dispatches central role events using the main queue.
 @param delegate Delegate of this class instance.
 */
- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue delegate:(id<CBCentralManagerDelegate>) delegate;

/**
 Constructor with array of known peripheral names.
 @param nameList Array of peripheral names of type NSString.
 @param queue The dispatch queue to use to dispatch the central role events.
 If its value is nil, the central manager dispatches central role events using the main queue.
 @param useStore If YES, then discovered peripheral UUIDs are stored in standardUserDefaults.
 @param delegate Delegate of this class instance.
 */
- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore delegate:(id<CBCentralManagerDelegate>) delegate;

#pragma mark - Peripheral Management
/** @name Peripheral Management */
/**
 Determines if peripheral is known by this app service.

 Used in conjunction with knownPeripheralNames. 
 
 @param peripheral found or retrieved peripheral
 @return YES is peripheral is to be managed by this app service.
 */

- (BOOL)isKnownPeripheral:(CBPeripheral *)peripheral;


/**
 Handler for discovered or found peripheral. This method is to be overridden.

 @param peripheral CoreBluetooth peripheral instance
 */
- (void)handleFoundPeripheral:(CBPeripheral *)peripheral;

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
 Remove yperipheral in ymsPeripherals and from standardUserDefaults if stored.
 
 @param yperipheral Instance of YMSCBPeripheral
 */
- (void)removePeripheral:(YMSCBPeripheral *)yperipheral;

/**
 Remove YMSCBPeripheral instance at index
 @param index The index from which to remove the object in ymsPeripherals. The value must not exceed the bounds of the array.
 */
- (void)removePeripheralAtIndex:(NSUInteger)index;

/**
 Remove all YMSCBPeripheral instances
 */
- (void)removeAllPeripherals;

/**
 Find YMSCBPeripheral instance matching peripheral
 @param peripheral peripheral corresponding with YMSCBPeripheral
 @return instance of YMSCBPeripheral
 */
- (YMSCBPeripheral *)findPeripheral:(CBPeripheral *)peripheral;

#pragma mark - Scan Methods
/** @name Scanning for Peripherals */
/**
 Start CoreBluetooth scan for peripherals. This method is to be overridden.
 
 The implementation of this method in a subclass must include the call to
 scanForPeripheralsWithServices:options:
 
 */
- (void)startScan;

/**
 Wrapper around the method scanForPeripheralWithServices:options: in CBCentralManager.
 
 If this method is invoked without involving a callback block, you must implement handleFoundPeripheral:.
 
 @param serviceUUIDs An array of CBUUIDs the app is interested in.
 @param options A dictionary to customize the scan, see CBCentralManagerScanOptionAllowDuplicatesKey.
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options;

/**
 Scans for peripherals that are advertising service(s), invoking a callback block for each peripheral
 that is discovered.

 @param serviceUUIDs An array of CBUUIDs the app is interested in.
 @param options A dictionary to customize the scan, see CBCentralManagerScanOptionAllowDuplicatesKey.
 @param discoverCallback Callback block to execute upon discovery of a peripheral. 
 The parameters of discoverCallback are:
 
 * `peripheral` - the discovered peripheral.
 * `advertisementData` - A dictionary containing any advertisement data.
 * `RSSI` - The current received signal strength indicator (RSSI) of the peripheral, in decibels.
 * `error` - The cause of a failure, if any.
 
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options withBlock:(void (^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error))discoverCallback;


/**
 Stop CoreBluetooth scan for peripherals.
 */
- (void)stopScan;


#pragma mark - Retrieve Methods
/** @name Retrieve Peripherals */

/**
 Retrieves a list of known peripherals by their UUIDs.
 
 @param identifiers A list of NSUUID objects.
 @return A list of peripherals.

 */
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;

/**
 Retrieves a list of the peripherals currently connected to the system and handles them using
 handleFoundPeripheral:
 

 Retrieves all peripherals that are connected to the system and implement 
 any of the services listed in <i>serviceUUIDs</i>.
 Note that this set can include peripherals which were connected by other 
 applications, which will need to be connected locally
 via connectPeripheral:options: before they can be used.

 @param identifiers A list of NSUUID services
 @return A list of CBPeripheral objects.
 */
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDS;


#pragma mark - CBCentralManager state handling methods
/** @name CBCentralManager manager state handling methods */
 
/**
 Handler for when manager state is powered on.
 */
- (void)managerPoweredOnHandler;

/**
 Handler for when manager state is unknown.
 */
- (void)managerUnknownHandler;

/**
 Handler for when manager state is powered off
 */
- (void)managerPoweredOffHandler;

/**
 Handler for when manager state is resetting.
 */
- (void)managerResettingHandler;

/**
 Handler for when manager state is unauthorized.
 */
- (void)managerUnauthorizedHandler;

/**
 Handler for when manager state is unsupported.
 */
- (void)managerUnsupportedHandler;

@end

