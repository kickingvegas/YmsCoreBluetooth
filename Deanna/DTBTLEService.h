//
//  DTBTLEService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class DTSensorTag;

/**
 NSNotifications
 */
extern NSString * const DTBTLEServicePowerOffNotification;


/**
 Protocols
 */
@protocol DTSensorTagDelegate <NSObject>

@end

@interface DTBTLEService : NSObject <CBCentralManagerDelegate>

@property (nonatomic, assign) id<DTSensorTagDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) DTSensorTag *sensorTag;
@property (nonatomic, assign) BOOL sensorTagEnabled;
@property (nonatomic, strong) NSMutableArray *peripherals;

+ (DTBTLEService *)sharedService;

- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

- (void)persistPeripherals;
- (void)loadPeripherals;


@end
