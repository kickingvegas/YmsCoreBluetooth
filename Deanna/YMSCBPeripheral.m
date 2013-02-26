//
//  YMSCBPeripheral.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBPeripheral.h"
#import "DEASimpleKeysService.h"
#import "YMSCBCharacteristic.h"


@implementation YMSCBPeripheral

- (id)initWithPeripheral:(CBPeripheral *)peripheral
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update {
    
    self = [super init];
    
    if (self) {
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
        
        _cbPeriperheral = peripheral;
        peripheral.delegate = self;

        _shouldPingRSSI = update;
        if (update == YES) {
            [peripheral readRSSI];
        }

    }

    return self;
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *service = self.serviceDict[key];
        YMSCBCharacteristic *ct = service.characteristicDict[@"service"];
        
        [tempArray addObject:ct.uuid];
    }
    
    result = tempArray;
    return result;
}

- (YMSCBService *)findService:(CBService *)service {
    YMSCBService *result;
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *btService = self.serviceDict[key];
        YMSCBCharacteristic *ct = btService.characteristicDict[@"service"];
        
        if ([service.UUID isEqual:ct.uuid]) {
            result = btService;
            break;
        }
        
    }
    return result;
}

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



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    YMSCBService *btService = [self findService:service];
    [btService syncCharacteristics:service.characteristics];
}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
    
    if ([yc.name isEqualToString:@"data"]) {
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
