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

/**
 NSNotifications
 */

/// Notification for CBCentralManager unknown state.
extern NSString * const YMSCBUnknownNotification;
extern NSString * const YMSCBResettingNotification;
extern NSString * const YMSCBUnsupportedNotification;
extern NSString * const YMSCBUnauthorizedNotification;
extern NSString * const YMSCBPoweredOffNotification;
extern NSString * const YMSCBPoweredOnNotification;

/**
 Protocols
 */
@protocol YMSCBAppServiceDelegate <NSObject>

/**
 Delegate method for when peripheral has been connected.
 */
- (void)didConnectPeripheral:(id)delegate;

/**
 Delegate method fo when peripheral has been disconnected.
 */
- (void)didDisconnectPeripheral:(id)delegate;

@end

/**
 Base class for defining a CoreBluetooth application service.

 Note that is not to be confused with a CoreBluetooth *service* where the term *service*
 has its own semantic definition with the context of the CoreBluetooth framework. Rather,
 an *application service* is meant here to define a set of functionality which is to be
 considered a sub-system of the application.
 
 YMSCBAppService is to be typically subclassed as a singleton instance.


 ## Global Constants

     extern NSString * const YMSCBUnknownNotification;
     extern NSString * const YMSCBResettingNotification;
     extern NSString * const YMSCBUnsupportedNotification;
     extern NSString * const YMSCBUnauthorizedNotification;
     extern NSString * const YMSCBPoweredOffNotification;
     extern NSString * const YMSCBPoweredOnNotification;

 ### Constants

 `YMSCBUnknownNotification` - notification for `CBCentralManagerStateUnknown`<br/>
 `YMSCBResettingNotification` - notification for `CBCentralManagerStateResetting`<br/>
 `YMSCBUnsupportedNotification` - notification for `CBCentralManagerStateUnsupported`<br/>
 `YMSCBUnauthorizedNotification` - notification for `CBCentralManagerStateUnauthorized`<br/>
 `YMSCBPoweredOffNotification` - notification for `CBCentralManagerStatePoweredOff`<br/>
 `YMSCBPoweredOnNotification` - notification for `CBCentralManagerStatePoweredOn`
 
 */
@interface YMSCBAppService : NSObject <CBCentralManagerDelegate>

/// Pointer to delegate.
@property (nonatomic, weak) id<YMSCBAppServiceDelegate> delegate;

/// Pointer to CBCentralManager. 
@property (nonatomic, strong) CBCentralManager *manager;

/// Array of DEASensorTag peripherals.
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;

/**
 Array of NSStrings to search to match CBPeripheral instances.
 
 Used in conjunction with [isAppServicePeripheral:]
 */
@property (nonatomic, strong) NSArray *peripheralSearchNames;

/// Flag to determine if scanning.
@property (nonatomic, assign) BOOL isScanning;

/**
 Determines if peripheral is to be managed by this app service.
 Used in conjunction with peripheralSearchNames.
 
 @param peripheral found or retrieved peripheral
 @return YES is peripheral is to be managed by this app service.
 */

- (BOOL)isAppServicePeripheral:(CBPeripheral *)peripheral;


/**
 Persist peripheral UUIDs.
 */
- (void)persistPeripherals;

/**
 Load peripheral UUIDs.
 */
- (void)loadPeripherals;


/**
 Handler for discovered or found peripheral.
 
 @param peripheral CoreBluetooth peripheral instance
 @param central CoreBluetooth central manager instance
 */
- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central;

/**
 Start CoreBluetooth scan for peripherals.
 */
- (void)startScan;

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
- (YMSCBPeripheral *)findYmsPeripheral:(CBPeripheral *)peripheral;

@end

