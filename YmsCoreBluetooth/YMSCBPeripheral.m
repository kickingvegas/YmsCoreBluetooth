// 
// Copyright 2013 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
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

        _willPingRSSI = update;
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
            btService.cbService = service;
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
    
    [btService updateCharacteristic:yc];
}

- (void)updateRSSI {
    [self.cbPeriperheral readRSSI];
    
}
    
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"RSSI: %@", peripheral.RSSI);
    
    if (self.willPingRSSI) {
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
    YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
    
    NSLog(@"write to service.characteristic: %@.%@", btService.name, yc.name);
    [btService updateCharacteristic:yc];
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

@end
