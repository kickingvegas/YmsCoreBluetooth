//
//  YMSBluetoothService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class DEASensorTag;

/**
 NSNotifications
 */
extern NSString * const YMSCBPowerOffNotification;


/**
 Protocols
 */
@protocol YMSBluetoothServiceDelegate <NSObject>

- (void)hasStoppedScanning:(id)delegate;
- (void)hasStartedScanning:(id)delegate;
- (void)didConnectPeripheral:(id)delegate;
- (void)didDisconnectPeripheral:(id)delegate;


@end

/**
 Application service definition for a CoreBluetooth service.
 
 Typically instantiated as a singleton.
 */
@interface YMSBluetoothService : NSObject <CBCentralManagerDelegate>

/// pointer to delegate
@property (nonatomic, weak) id<YMSBluetoothServiceDelegate> delegate;

/// pointer to CBCentralManager
@property (nonatomic, strong) CBCentralManager *manager;

/// array of DEASensorTag peripherals
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;

/// flag to determine if connected. is this used? TODO
@property (nonatomic, assign) BOOL isConnected;

/// flag to determine if scanning. is this used? TODO
@property (nonatomic, assign) BOOL isScanning;

/**
 Return singleton instance.
 */
+ (YMSBluetoothService *)sharedService;

/**
 Return if peripheral is a TI SensorTag.
 
 @param peripheral peripheral instance to test if TI SensorTag.
 
 */
- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

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
 Find DEASensorTag instance matching peripheral
 @param peripheral peripheral corresponding with DEASensorTag
 @return instance of DEASensorTag
 */
- (DEASensorTag *)findYmsPeripheral:(CBPeripheral *)peripheral;

@end




