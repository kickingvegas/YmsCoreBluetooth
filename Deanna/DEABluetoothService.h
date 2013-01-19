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

@end

@interface DEABluetoothService : NSObject <CBCentralManagerDelegate>

@property (nonatomic, assign) id<DTSensorTagDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) DEASensorTag *sensorTag;
@property (nonatomic, assign) BOOL sensorTagEnabled;
@property (nonatomic, assign) BOOL sensorTagConnected;
@property (nonatomic, strong) NSMutableArray *peripherals;

+ (DEABluetoothService *)sharedService;

- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

- (void)persistPeripherals;
- (void)loadPeripherals;


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central;


@end
