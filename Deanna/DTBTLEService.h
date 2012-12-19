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

@interface DTBTLEService : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) DTSensorTag *sensorTag;
@property (nonatomic, assign) BOOL sensorTagEnabled;


+ (DTBTLEService *)sharedService;

- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral;

@end
