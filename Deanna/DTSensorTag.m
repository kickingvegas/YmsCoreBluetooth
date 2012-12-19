//
//  DTSensorTag.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#include "TISensorTag.h"

#import "DTSensorTag.h"
#import "YMSCBUtils.h"
//#import "DTSensorConfig.h"
//#import "DTTemperatureConfig.h"
//#import "DTAccelerometerConfig.h"

#import "DTTemperatureBTService.h"
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
        
        _sensorServices = tempDict;
    }
    
    return self;
}


//- (void)addPeripheralsObject:(id)object {
//    [self.peripherals addObject:object];
//    
//    for (id key in self.sensorConfigs) {
//        DTSensorConfig *config = self.sensorConfigs[key];
//        config.peripheral = object;
//    }
//}
//
//
//- (void)removeObjectFromPeripheralsAtIndex:(NSUInteger)index {
//    for (id key in self.sensorConfigs) {
//        DTSensorConfig *config = self.sensorConfigs[key];
//        config.peripheral = nil;
//    }
//    
//    [self.peripherals removeObjectAtIndex:index];
//}



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
    
    DTCharacteristic *dtc = btService.characteristicMap[@"data"];
    
    [peripheral setNotifyValue:YES forCharacteristic:dtc.characteristic];
    
    dtc = btService.characteristicMap[@"config"];

    int8_t payload = 0x1;
    NSData *data = [NSData dataWithBytes:&payload length:1];

    [peripheral writeValue:data forCharacteristic:dtc.characteristic type:CBCharacteristicWriteWithResponse];
    
 }
    

// 11
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    DTSensorBTService *btService = [self findService:characteristic.service];
    DTCharacteristic *dtc = [btService findCharacteristic:characteristic];

    
    if ([btService.name isEqualToString:@"temperature"]) {

        if ([dtc.name isEqualToString:@"data"]) {
            NSData *data = characteristic.value;
            char val[data.length];
            [data getBytes:&val length:data.length];
            
            
            int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
            
            int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));
            
            NSLog(@"didUpdateValue: %@ data: amb: %d obj: %d", btService.name, amb, objT);

        }
    }
                             
    else if ([btService.name isEqualToString:@"accelerometer"]) {
        
        
        if ([dtc.name isEqualToString:@"data"]) {
            
            NSData *data = characteristic.value;
            char val[data.length];
            [data getBytes:&val length:data.length];
            
            int16_t x = val[0];
            int16_t y = val[1];
            int16_t z = val[2];
            
            NSLog(@"didUpdateValue: %@ data: %d %d %d", btService.name, x, y, z);

        }
    }
}

    //12
    //[peripheral setNotifyValue: forCharacteristic:];
    
    
    
//    for (NSString *key in self.sensorConfigs) {
//        DTSensorConfig *sensor = (DTSensorConfig *)[self.sensorConfigs objectForKey:key];
//        CBService *service = characteristic.service;
//
//        if ([sensor isMatchToService:service]) {
//            
//            if ([key isEqualToString:@"temperature"]) {
//                
//                if ([sensor isMatchToCharacteristic:characteristic withKey:@"data"]) {
//                    
//                    NSData *data = characteristic.value;
//                    char val[data.length];
//                    [data getBytes:&val length:data.length];
//                    
//                    
//                    
//                    int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
//
//                    int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));
//
//
//                    NSLog(@"didUpdateValue: %@ data: amb: %d obj: %d", sensor.name, amb, objT);
//                }
//                
//            }
//            
//            else if ([key isEqualToString:@"accelerometer"]) {
//                //NSLog(@"didUpdateValue: accelerometer");
//                
//                if ([sensor isMatchToCharacteristic:characteristic withKey:@"data"]) {
//                    
//                    NSData *data = characteristic.value;
//                    char val[data.length];
//                    [data getBytes:&val length:data.length];
//                    
//                    int16_t x = val[0];
//                    int16_t y = val[1];
//                    int16_t z = val[2];
//                    
//                    
//                    NSLog(@"didUpdateValue: %@ data: %d %d %d", sensor.name, x, y, z);
//                }
//
//            }
//            
//        }
//        
//    }
//}




    
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}
    
    
    
    
    







@end
