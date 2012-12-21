//
//  DTSensorTag.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTSensorTag.h"
#import "DTTemperatureBTService.h"
#import "DTAccelerometerBTService.h"
#import "DTSimpleKeysBTService.h"
#import "DTCharacteristic.h"


@implementation DTSensorTag


- (id)init {
    self = [super init];
    
    if (self) {
        
        _peripherals = [[NSMutableArray alloc] init];
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        DTTemperatureBTService *ts = [[DTTemperatureBTService alloc] initWithName:@"temperature"];
        tempDict[ts.name] = ts;
        
        DTAccelerometerBTService *as = [[DTAccelerometerBTService alloc] initWithName:@"accelerometer"];
        tempDict[as.name] = as;
        
        /**
         * TODO: Support for 1.3 firmware
        DTSimpleKeysBTService *sks = [[DTSimpleKeysBTService alloc] initWithName:@"simplekeys"];
        tempDict[sks.name] = sks;
         */
        
        _sensorServices = tempDict;
    }
    
    return self;
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.sensorServices) {
        DTSensorBTService *service = self.sensorServices[key];
        DTCharacteristic *ct = service.characteristicMap[@"service"];
        
        [tempArray addObject:ct.uuid];
    }
    
    result = tempArray;
    return result;
}

- (DTSensorBTService *)findService:(CBService *)service {
    DTSensorBTService *result;
    
    for (NSString *key in self.sensorServices) {
        DTSensorBTService *btService = self.sensorServices[key];
        DTCharacteristic *ct = btService.characteristicMap[@"service"];
        
        if ([service.UUID isEqual:ct.uuid]) {
            result = btService;
            break;
        }
        
    }
    return result;
}



// 7
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        DTSensorBTService *btService = [self findService:service];
        
        if (btService != nil) {
            if (btService.service == nil) {
                btService.service = service;
            }
        }
        [peripheral discoverCharacteristics:[btService characteristics] forService:service];
    }
}


// 9
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    DTSensorBTService *btService = [self findService:service];
    [btService syncCharacteristics:service.characteristics];
    
    /**
     * TODO: Support for 1.3 firmware
    if ([btService.name isEqualToString:@"simplekeys"]) {
        [btService setNotifyValue:YES forCharacteristicName:@"data"];
    }
    */
    
    [btService requestConfig];
}
    

// 11
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    DTSensorBTService *btService = [self findService:characteristic.service];
    DTCharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    if ([dtc.name isEqualToString:@"config"]) {
        NSData *data = [btService responseConfig];

        if ([YMSCBUtils dataToByte:data] == 0x1) {
            btService.isEnabled = YES;
        }
        else {
            btService.isEnabled = NO;
        }
    }


    if ([btService.name isEqualToString:@"temperature"]) {

        if ([dtc.name isEqualToString:@"data"]) {
            DTTemperatureBTService *ts = (DTTemperatureBTService *)btService;
            [ts updateTemperature];
         }
    }
                             
    else if ([btService.name isEqualToString:@"accelerometer"]) {
        if ([dtc.name isEqualToString:@"data"]) {
            
            DTAccelerometerBTService *as = (DTAccelerometerBTService *)btService;
            [as updateAcceleration];
            
        }
    }
    
    /**
     * Support for 1.3 firmware
    else if ([btService.name isEqualToString:@"simplekeys"]) {
        if ([dtc.name isEqualToString:@"data"]) {
            NSLog(@"hit a key");
        }
    }
    */
}

    
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}
    


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
    

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    DTSensorBTService *btService = [self findService:characteristic.service];
    DTCharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    NSLog(@"write to service.characteristic: %@.%@", btService.name, dtc.name);
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

@end
