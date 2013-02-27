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

- (void)didConnectPeripheral:(id)delegate;

- (void)didDisconnectPeripheral:(id)delegate;

@end

/**
 Application service definition for a CoreBluetooth service.
 
 Typically instantiated as a singleton.
 */
@interface YMSCBAppService : NSObject <CBCentralManagerDelegate>

/// pointer to delegate
@property (nonatomic, weak) id<YMSCBAppServiceDelegate> delegate;

/// pointer to CBCentralManager
@property (nonatomic, strong) CBCentralManager *manager;

/// array of DEASensorTag peripherals
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;

/**
 array of NSStrings to search to match CBPeripheral instances
 
 Used in conjunction with [isAppServicePeripheral:]
 */
 
@property (nonatomic, strong) NSArray *peripheralSearchNames;

/// flag to determine if scanning.
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




