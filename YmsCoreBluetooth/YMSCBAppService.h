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


#define kYMSCBVersion "0.92"
extern NSString *const YMSCBVersion;

@class YMSCBPeripheral;
@class YMSCBAppService;

typedef void (^YMSCBDiscoverCallbackBlockType)(CBPeripheral *, NSDictionary *, NSNumber *, NSError *);
typedef void (^YMSCBConnectCallbackBlockType)(YMSCBPeripheral *, NSError *);
typedef void (^YMSCBRetrieveCallbackBlockType)(CBPeripheral *);

/**
 Base class for defining a CoreBluetooth application service.
 
 Note that this class is not to be confused with a CoreBluetooth *service*. Rather,
 an *application service* is meant here to define a set of functionality which is to be
 considered a sub-system of the application.

 YMSCBAppService manages all CoreBluetooth interactions by the parent application. The class manages
 an an instance of the CBCentralManager (manager) and all the Bluetooth LE (BLE) peripherals discovered by
 it.
 
 YMSCBAppService is intended to be subclassed to handle the different types of BLE peripherals
 the application is to communicate with. The implementation of handleFoundPeripheral: handles the details
 of discovering a BLE peripheral.
 
 The subclass is typically implemented (though not necessarily) as a singleton.
 
 All discovered BLE peripherals are stored in the array ymsPeripherals. 
 
 */
@interface YMSCBAppService : NSObject <CBCentralManagerDelegate>

/** @name Properties */
/**
 Pointer to delegate.
 
 The delegate object will be sent CBCentralManagerDelegate messages received by manager.
 */
@property (nonatomic, weak) id<CBCentralManagerDelegate> delegate;

/**
 The CBCentralManager object.
 
 In typical practice, there is only one instance of CBCentralManager and it is located in a singleton instance of YMSCBAppService.
 This class listens to CBCentralManagerDelegate messages sent by manager, which in turn forwards those messages to delegate.
 */
@property (nonatomic, strong) CBCentralManager *manager;

/**
 Array of YMSCBPeripheral instances.
 
 This array holds all YMSCBPeripheral instances discovered or retrieved by manager.
 */
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;

/**
 Array of NSStrings to search to match CBPeripheral instances.
 
 Used in conjunction with isKnownPeripheral:.  
 This value is typically initialized using initWithKnownPeripheralNames:queue:.
 */
@property (nonatomic, strong) NSArray *knownPeripheralNames;

/// Flag to determine if manager is scanning.
@property (nonatomic, assign) BOOL isScanning;

/// Count of ymsPeripherals.
@property (nonatomic, readonly, assign) NSUInteger count;

/// API version.
@property (nonatomic, readonly, assign) NSString *version;


/// Peripheral Discovered Callback
@property (nonatomic, strong) YMSCBDiscoverCallbackBlockType discoveredCallback;

/// Peripheral Retreived Callback
@property (nonatomic, strong) YMSCBRetrieveCallbackBlockType retrievedCallback;

/// Peripheral Connection Callback Dictionary
@property (nonatomic, strong) NSMutableDictionary *connectionCallbackDict;

/// If YES, then discovered peripheral UUIDs are stored in standardUserDefaults.
@property (nonatomic, assign) BOOL useStoredPeripherals;

#pragma mark - Constructors
/** @name Initializing YMSCBAppService */
/**
 Constructor with array of known peripheral names.
 
 By default, this constructor will not use stored peripherals from standardUserDefaults.
 
 @param nameList Array of peripheral names of type NSString.
 @param queue The dispatch queue to use to dispatch the central role events. 
 If its value is nil, the central manager dispatches central role events using the main queue.
 */
- (id)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue;

/**
 Constructor with array of known peripheral names.
 @param nameList Array of peripheral names of type NSString.
 @param queue The dispatch queue to use to dispatch the central role events.
 If its value is nil, the central manager dispatches central role events using the main queue.
 @param useStore If YES, then discovered peripheral UUIDs are stored in standardUserDefaults.
 */
- (id)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore;

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
  Handler for connected peripheral. This method is to be overridden.
 
  @param peripheral CoreBluetooth peripheral instance
 */
- (void)handleConnectedPeripheral:(CBPeripheral *)peripheral;



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
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options withBlock:(void (^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error))discoverCallback;


/**
 Stop CoreBluetooth scan for peripherals.
 */
- (void)stopScan;

#pragma mark - Connect Methods
/** @name Connecting to Peripherals */
/**
 Connect to peripheral.
 
 This method is to be overridden.
 @param peripheral Peripheral to connect.
 */
- (void)connect:(YMSCBPeripheral *)peripheral;

/**
 Connect peripheral at index in ymsPeripherals.
 
 @param index Index value of peripheral in ymsPeripherals.
 @param options A dictionary to customize the behavior of the connection. See "Peripheral Connection Options" for CBCentralManager.
 */
- (void)connectPeripheralAtIndex:(NSUInteger)index options:(NSDictionary *)options;

/**
 Connect peripheral at index in ymsPeripherals with callback block.
 
 @param index Index value of peripheral in ymsPeripherals.
 @param options A dictionary to customize the behavior of the connection. See "Peripheral Connection Options" for CBCentralManager.
 @param connectCallback Callback block to execute upon connection.
 */
- (void)connectPeripheralAtIndex:(NSUInteger)index options:(NSDictionary *)options withBlock:(void (^)(YMSCBPeripheral *yp, NSError *error))connectCallback;

/**
 Disconnect peripheral.
 
 @param index index value of peripheral in ymsPeripherals to disconnect.
 */
- (void)disconnectPeripheralAtIndex:(NSUInteger)index;

/**
 Establishes connection to peripheral.
 
 @param peripheral The peripheral to which manager is attempting to connect.
 @param options A dictionary to customize the behavior of the connection. See "Peripheral Connection Options" for CBCentralManager.
 */
- (void)connectPeripheral:(YMSCBPeripheral *)peripheral options:(NSDictionary *)options;

/**
 Establishes connection to peripheral with callback block.
 
 @param peripheral The peripheral to which manager is attempting to connect.
 @param options A dictionary to customize the behavior of the connection. See "Peripheral Connection Options" for CBCentralManager.
 @param connectCallback Callback block to handle peripheral connection.
 */
- (void)connectPeripheral:(YMSCBPeripheral *)peripheral
                  options:(NSDictionary *)options
                withBlock:(void (^)(YMSCBPeripheral *yp, NSError *error))connectCallback;


#pragma mark - Cancel Method
/** @name Cancelling a Connection Request */
/**
 Cancels an active or pending local connection to a peripheral.
 
 @param peripheral The peripheral to which the central manager is either trying to connect or has already connected.
 */
- (void)cancelPeripheralConnection:(YMSCBPeripheral *)peripheral;


#pragma mark - Retrieve Methods
/** @name Retrieve Peripherals */

/**
 Retrieves a list of known peripherals by their UUIDs.
 */
- (void)retrieveConnectedPeripherals;

/**
 Retrieves a list of known peripherals by their UUIDs and handles them using a callback block.
 
 @param retrieveCallback Callback block to handle each retrieved peripheral.
 */
- (void)retrieveConnectedPeripheralswithBlock:(void (^)(CBPeripheral *peripheral))retrieveCallback;

/**
 Retrieves a list of the peripherals currently connected to the system and handles them using
 a callback block.
 
 @param peripheralUUIDs An array of CFUUIDRef objects from which CBPeripheral objects can be retrieved.
 */
- (void)retrievePeripherals:(NSArray *)peripheralUUIDs;


/**
 Retrieves a list of the peripherals currently connected to the system and handles them using
 a callback block.
 
 @param peripheralUUIDs An array of CFUUIDRef objects from which CBPeripheral objects can be retrieved. 
 @param retrieveCallback Callback block to handle each retrieved peripheral.
 */
- (void)retrievePeripherals:(NSArray *)peripheralUUIDs
                  withBlock:(void (^)(CBPeripheral *peripheral))retrieveCallback;


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

