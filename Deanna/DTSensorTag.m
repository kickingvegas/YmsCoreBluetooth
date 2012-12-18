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
#import "DTSensorConfig.h"
#import "DTTemperatureConfig.h"
#import "DTAccelerometerConfig.h"


@implementation DTSensorTag


- (id)init {
    self = [super init];
    
    if (self) {
        
        _peripherals = [[NSMutableArray alloc] init];
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        DTTemperatureConfig *ts = [[DTTemperatureConfig alloc] initWithBase:&_base];
        tempDict[ts.name] = ts;
        
        DTAccelerometerConfig *as = [[DTAccelerometerConfig alloc] initWithBase:&_base];
        tempDict[as.name] = as;
    
        
        _sensorConfigs = tempDict;
    }
    
    return self;
}


- (void)addPeripheralsObject:(id)object {
    [self.peripherals addObject:object];
    
    for (id key in self.sensorConfigs) {
        DTSensorConfig *config = self.sensorConfigs[key];
        config.peripheral = object;
    }
}


- (void)removeObjectFromPeripheralsAtIndex:(NSUInteger)index {
    for (id key in self.sensorConfigs) {
        DTSensorConfig *config = self.sensorConfigs[key];
        config.peripheral = nil;
    }
    
    [self.peripherals removeObjectAtIndex:index];
}



- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.sensorConfigs) {
        DTSensorConfig *config = [self.sensorConfigs objectForKey:key];
        [tempArray addObject:[CBUUID UUIDWithString:config.service]];
    }
    
    result = tempArray;
    
    return result;
}

- (DTSensorConfig *)getConfigFromService:(CBService *)service {
    DTSensorConfig *sensor;
    
    for (NSString *key in self.sensorConfigs) {
        sensor = (DTSensorConfig *)[self.sensorConfigs objectForKey:key];
        if ([sensor isMatchToService:service])
            break;
    }
    
    return sensor;
}


// 7
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 8
    for (CBService *svc in peripheral.services) {
        DTSensorConfig *config = [self getConfigFromService:svc];
        [peripheral discoverCharacteristics:[config genCharacteristics] forService:svc];
    }
}


// 9
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // 10
    //[peripheral readValueForCharacteristic:];
    
//    DTSensorConfig *config = [self getConfigFromService:service];
//    
//    for (CBCharacteristic *ct in service.characteristics) {
//
//        for (CBUUID *configct in [config genCharacteristics]) {
//            if ([ct.UUID isEqual:configct]) {
//                [peripheral readValueForCharacteristic:ct];
//            }
//        }
//        
//        
//        
//        for (NSString *key in [config genCharacteristics]) {
//            if ([config isMatchToCharacteristic:ct withKey:key]) {
//                [peripheral readValueForCharacteristic:ct];
//            }
//            
//            if ([key isEqualToString:@"data"]) {
//                [peripheral setNotifyValue:YES forCharacteristic:ct];
//            }
//            
//            else if ([key isEqualToString:@"config"]) {
//                int8_t payload = 0x1;
//                NSData *data = [NSData dataWithBytes:&payload length:1];
//                
//                [peripheral writeValue:data forCharacteristic:ct type:CBCharacteristicWriteWithResponse];
//
//            }
//        }
//    }
    
    
    for (id key in self.sensorConfigs) {
        DTSensorConfig *sensor = (DTSensorConfig *)[self.sensorConfigs objectForKey:key];
        if ([sensor isMatchToService:service]) {
            
            for (CBCharacteristic *c in service.characteristics) {
                
                [peripheral readValueForCharacteristic:c];
                
                if ([sensor isMatchToCharacteristic:c withKey:@"config"]) {
                    int8_t payload = 0x1;
                    NSData *data = [NSData dataWithBytes:&payload length:1];
                    
                    [peripheral writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
                }
                
                
                else if ([sensor isMatchToCharacteristic:c withKey:@"data"]) {
                    [peripheral setNotifyValue:YES forCharacteristic:c];
                }
            }
            
        }
        
    }
}
    

// 11
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //12
    //[peripheral setNotifyValue: forCharacteristic:];
    
    
    
    for (NSString *key in self.sensorConfigs) {
        DTSensorConfig *sensor = (DTSensorConfig *)[self.sensorConfigs objectForKey:key];
        CBService *service = characteristic.service;

        if ([sensor isMatchToService:service]) {
            
            if ([key isEqualToString:@"temperature"]) {
                
                if ([sensor isMatchToCharacteristic:characteristic withKey:@"data"]) {
                    
                    NSData *data = characteristic.value;
                    char val[data.length];
                    [data getBytes:&val length:data.length];
                    
                    
                    
                    int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));

                    int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));


                    NSLog(@"didUpdateValue: %@ data: amb: %d obj: %d", sensor.name, amb, objT);
                }
                
            }
            
            else if ([key isEqualToString:@"accelerometer"]) {
                //NSLog(@"didUpdateValue: accelerometer");
                
                if ([sensor isMatchToCharacteristic:characteristic withKey:@"data"]) {
                    
                    NSData *data = characteristic.value;
                    char val[data.length];
                    [data getBytes:&val length:data.length];
                    
                    int16_t x = val[0];
                    int16_t y = val[1];
                    int16_t z = val[2];
                    
                    
                    NSLog(@"didUpdateValue: %@ data: %d %d %d", sensor.name, x, y, z);
                }

            }
            
        }
        
    }
}

    

//    for (id key in self.sensorConfigs) {
//        DTSensorConfig *sensor = (DTSensorConfig *)[self.sensorConfigs objectForKey:key];
//        
//        if ([sensor.name isEqualToString:@"temperature"]) {
//            if ([characteristic.UUID isEqual:[sensor genCBUUID:@"config"]]) {
//                NSData *data = characteristic.value;
//                char val[data.length];
//                [data getBytes:&val length:data.length];
//                int8_t foo = val[0];
//                
//                NSLog(@"didUpdateValue: %@ config: %d", sensor.name, foo);
//                
//                if (foo == 0) {
//                    int8_t newData = 0x1;
//                    [peripheral writeValue:[NSData dataWithBytes:&newData length:1] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//                }
//                
//                
//                     
//                
//                
//                
//            }
//            
//            else if ([characteristic.UUID isEqual:[sensor genCBUUID:@"data"]]) {
//                NSData *data = characteristic.value;
//                char val[data.length];
//                [data getBytes:&val length:data.length];
//                
//                int16_t foo;
//                
//                foo = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
//                
//                NSLog(@"didUpdateValue: %@ data: %d", sensor.name, foo);
//                
//            }
//
//            break;
//
//        }
    
        //        for (CBUUID *cbuuid in [sensor genCharacteristics]) {
//            if ([characteristic.UUID isEqual:cbuuid]) {
//                
//                NSData *data = characteristic.value;
//                
//                char val[data.length];
//                
//                [data getBytes:&val length:data.length];
//                
//                NSLog(@"didUpdateValue: %@: %s", sensor.name, val);
//                breakOuter = YES;
//                break;
//            }
//        }
        


    
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}
    
    
    
    
    







@end
