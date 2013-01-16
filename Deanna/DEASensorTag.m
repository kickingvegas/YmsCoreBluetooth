//
//  DTSensorTag.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEASensorTag.h"
#import "DEATemperatureService.h"
#import "DEAAccelerometerService.h"
#import "DEASimpleKeysService.h"
#import "DEACharacteristic.h"


@implementation DEASensorTag


- (id)init {
    self = [super init];
    
    if (self) {
        
        _peripherals = [[NSMutableArray alloc] init];
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature"];
        tempDict[ts.name] = ts;
        
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer"];
        tempDict[as.name] = as;
        
        /**
         * TODO: Support for 1.3 firmware
                  */
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys"];
        [sks turnOn];
        tempDict[sks.name] = sks;
        
        _sensorServices = tempDict;
    }
    
    return self;
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.sensorServices) {
        DEABaseService *service = self.sensorServices[key];
        DEACharacteristic *ct = service.characteristicMap[@"service"];
        
        [tempArray addObject:ct.uuid];
    }
    
    result = tempArray;
    return result;
}

- (DEABaseService *)findService:(CBService *)service {
    DEABaseService *result;
    
    for (NSString *key in self.sensorServices) {
        DEABaseService *btService = self.sensorServices[key];
        DEACharacteristic *ct = btService.characteristicMap[@"service"];
        
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
        DEABaseService *btService = [self findService:service];
        
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
    DEABaseService *btService = [self findService:service];
    [btService syncCharacteristics:service.characteristics];
    
    if ([btService.name isEqualToString:@"simplekeys"]) {
        [btService setNotifyValue:YES forCharacteristicName:@"data"];
    }
    else {
        [btService requestConfig];
    }
}


// 11
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    DEABaseService *btService = [self findService:characteristic.service];
    DEACharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    if ([dtc.name isEqualToString:@"config"]) {
        NSData *data = [btService responseConfig];

        if ([YMSCBUtils dataToByte:data] == 0x1) {
            btService.isEnabled = YES;
        }
        else {
            btService.isEnabled = NO;
        }
    }
    
    else if ([dtc.name isEqualToString:@"data"]) {
        [btService update];
    }


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
    
    DEABaseService *btService = [self findService:characteristic.service];
    DEACharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    NSLog(@"write to service.characteristic: %@.%@", btService.name, dtc.name);
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

@end
