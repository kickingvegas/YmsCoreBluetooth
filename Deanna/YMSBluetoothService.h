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
extern NSString * const YMSCBPowerOffNotification;


/**
 Protocols
 */
@protocol DEABluetoothServiceDelegate <NSObject>

- (void)hasStoppedScanning:(id)delegate;
- (void)hasStartedScanning:(id)delegate;
- (void)didConnectPeripheral:(id)delegate;
- (void)didDisconnectPeripheral:(id)delegate;


@end


@interface YMSBluetoothService : NSObject <CBCentralManagerDelegate>

@property (nonatomic, weak) id<DEABluetoothServiceDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSMutableArray *ymsPeripherals;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isScanning;

+ (YMSBluetoothService *)sharedService;

- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

- (void)persistPeripherals;
- (void)loadPeripherals;


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central;

- (void)startScan;
- (void)stopScan;
- (void)connectPeripheral:(NSUInteger)index;
- (void)disconnectPeripheral:(NSUInteger)index;

- (DEASensorTag *)findYmsPeripheral:(CBPeripheral *)peripheral;

@end




