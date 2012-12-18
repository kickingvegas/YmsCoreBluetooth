//
//  DTBTLEService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//
#include "TISensorTag.h"

#import "DTBTLEService.h"
#import "DTSensorTag.h"

static DTBTLEService *sharedBTLEService;

@implementation DTBTLEService

+ (DTBTLEService *)sharedService {
    if (sharedBTLEService == nil) {
        sharedBTLEService = [[super allocWithZone:NULL] init];
    }
    return sharedBTLEService;
}


- (id)init {
    self = [super init];
    
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        [_manager scanForPeripheralsWithServices:nil options:nil];

    }
    
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            break;
            
        case CBCentralManagerStateUnknown:
            break;
            
        case CBCentralManagerStatePoweredOff:
            break;
            
        case CBCentralManagerStateResetting:
            break;
            
        case CBCentralManagerStateUnauthorized:
            break;
            
        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // 3
    //
    
    // 4
    
    if ([self isSensorTagPeripheral:peripheral]) {
        NSLog(@"hey this matches;");
        self.sensorTag = [[DTSensorTag alloc] init];
        
        //[self.sensorTag addPeripheralsObject:peripheral];
        [self.sensorTag.peripherals addObject:peripheral];
        
        peripheral.delegate = self.sensorTag;
        [central connectPeripheral:peripheral options:nil];
        
        [self.manager stopScan];
    }

    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 6
    
    if ([self isSensorTagPeripheral:peripheral]) {
        
        [peripheral discoverServices:[self.sensorTag services]];

    }
    

}


- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral {
    BOOL result = NO;
    
    CBUUID *test = [CBUUID UUIDWithString:@"" kSensorTag_IDENTIFIER];
    CBUUID *control = [CBUUID UUIDWithCFUUID:peripheral.UUID];
    
    result = [test isEqual:control];
    return result;
}



@end
