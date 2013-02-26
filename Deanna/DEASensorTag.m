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
#import "YMSCBCharacteristic.h"


@implementation DEASensorTag


- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    
    if (self) {
        
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature"];
        tempDict[ts.name] = ts;
        
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer"];
        tempDict[as.name] = as;
        
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys"];
        [sks turnOn];
        tempDict[sks.name] = sks;
        
        _sensorServices = tempDict;
        
        _cbPeriperheral = peripheral;
        peripheral.delegate = self;
        
        
        _shouldPingRSSI = YES;
        [peripheral readRSSI];
        

    }
    
    return self;
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.sensorServices) {
        YMSCBService *service = self.sensorServices[key];
        YMSCBCharacteristic *ct = service.characteristicMap[@"service"];
        
        [tempArray addObject:ct.uuid];
    }
    
    result = tempArray;
    return result;
}

- (YMSCBService *)findService:(CBService *)service {
    YMSCBService *result;
    
    for (NSString *key in self.sensorServices) {
        YMSCBService *btService = self.sensorServices[key];
        YMSCBCharacteristic *ct = btService.characteristicMap[@"service"];
        
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
        YMSCBService *btService = [self findService:service];
        
        if (btService != nil) {
            if (btService.cbService == nil) {
                btService.cbService = service;
            }
        }
        [peripheral discoverCharacteristics:[btService characteristics] forService:service];
    }
}


// 9
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    YMSCBService *btService = [self findService:service];
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
    
    
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    if ([dtc.name isEqualToString:@"config"]) {
        /*
        NSData *data = [btService responseConfig];

        if ([YMSCBUtils dataToByte:data] == 0x1) {
            btService.isEnabled = YES;
        }
        else {
            btService.isEnabled = NO;
        }
         */
    }
    
    else if ([dtc.name isEqualToString:@"data"]) {
        [btService update];
    }


}

- (void)updateRSSI {
    [self.cbPeriperheral readRSSI];
    
}
    
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"RSSI: %@", peripheral.RSSI);
    
    if (self.shouldPingRSSI) {
        [self performSelector:@selector(updateRSSI) withObject:self afterDelay:5];
    }
    
}
    


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
    

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    NSLog(@"write to service.characteristic: %@.%@", btService.name, dtc.name);
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

@end
