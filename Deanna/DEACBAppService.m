//
//  DEACBAppService.m
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEACBAppService.h"
#import "DEASensorTag.h"

static DEACBAppService *sharedCBAppService;

@implementation DEACBAppService


- (id)init {
    self = [super init];
    
    if (self) {
        self.peripheralSearchNames = @[@"TI BLE Sensor Tag", @"SensorTag"];
    }
    
    return self;
}


+ (DEACBAppService *)sharedService {
    if (sharedCBAppService == nil) {
        sharedCBAppService = [[super allocWithZone:NULL] init];
    }
    return sharedCBAppService;
}


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central {
    
    DEASensorTag *sensorTag;
    
    [self stopScan];
    
    sensorTag = (DEASensorTag *)[self findYmsPeripheral:peripheral];
    
    if (sensorTag == nil) {
        sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral
                                                      baseHi:kSensorTag_BASE_ADDRESS_HI
                                                      baseLo:kSensorTag_BASE_ADDRESS_LO
                                                  updateRSSI:YES];

        [self.ymsPeripherals addObject:sensorTag];
        
        if (peripheral.isConnected == NO) {
            [central connectPeripheral:peripheral options:nil];
        }
    }
}



@end
