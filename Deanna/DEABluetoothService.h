//
//  DTBTLEService.h
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
extern NSString * const DTBTLEServicePowerOffNotification;


/**
 Protocols
 */
@protocol DTSensorTagDelegate <NSObject>

- (void)hasStoppedScanning:(id)delegate;
- (void)hasStartedScanning:(id)delegate;
- (void)didConnectPeripheral:(id)delegate;
- (void)didDisconnectPeripheral:(id)delegate;


@end


@interface DEABluetoothService : NSObject <CBCentralManagerDelegate>

@property (nonatomic, weak) id<DTSensorTagDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) DEASensorTag *sensorTag;
//@property (nonatomic, assign) BOOL sensorTagEnabled;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, assign) BOOL isScanning;

+ (DEABluetoothService *)sharedService;

- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

- (void)persistPeripherals;
- (void)loadPeripherals;


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central;

- (void)startScan;
- (void)stopScan;
- (void)connectPeripheral;
- (void)disconnectPeripheral;

@end




