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

#import "YMSCBService.h"
#import "YMSCBUtils.h"
#import "YMSCBCharacteristic.h"


@implementation YMSCBService


- (id)init {
    self = [super init];
    
    if (self) {
        _characteristicDict = [[NSMutableDictionary alloc] init];
        _base.hi = kSensorTag_BASE_ADDRESS_HI;
        _base.lo = kSensorTag_BASE_ADDRESS_LO;
    }
    
    return self;
}

- (id)initWithName:(NSString *)oName {
    // Classes which inherit from this class must invoke this method via super.
    self = [self init];
    if (self) {
        self.name = oName;
    }
    return self;
}

- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset {
    YMSCBCharacteristic *yc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntOffset:addrOffset];
    
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addrOffset];
    
    [self.characteristicDict setObject:yc forKey:cname];
}

- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr {
    
    YMSCBCharacteristic *yc;
    NSString *addrString = [NSString stringWithFormat:@"%x", addr];
    
    
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addr];
    
    [self.characteristicDict setObject:yc forKey:cname];
}


- (NSArray *)characteristics {
    NSArray *tempArray = [self.characteristicDict allValues];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self.characteristicDict count]];
    
    for (YMSCBCharacteristic *yc in tempArray) {
        [result addObject:yc.uuid];
    }
    
    return result;
}


- (void)syncCharacteristics:(NSArray *)foundCharacteristics {
    for (NSString *key in self.characteristicDict) {
        YMSCBCharacteristic *yc = self.characteristicDict[key];
        for (CBCharacteristic *ct in foundCharacteristics) {
            if ([yc.uuid isEqual:ct.UUID]) {
                yc.cbCharacteristic = ct;
                break;
            }
        }
    }
    
    self.isEnabled = YES;
}

- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct {
    YMSCBCharacteristic *result;
    for (NSString *key in self.characteristicDict) {
        YMSCBCharacteristic *yc = self.characteristicDict[key];
            
        if ([yc.cbCharacteristic.UUID isEqual:ct.UUID]) {
            result = yc;
            break;
        }
    }
    return result;
}


- (void)setNotifyValue:(BOOL)notifyValue forCharacteristic:(CBCharacteristic *)characteristic {
    [self.cbService.peripheral setNotifyValue:notifyValue
                          forCharacteristic:characteristic];
    
}

- (void)setNotifyValue:(BOOL)notifyValue forCharacteristicName:(NSString *)cname {
    YMSCBCharacteristic *yc = self.characteristicDict[cname];
    [self.cbService.peripheral setNotifyValue:notifyValue forCharacteristic:yc.cbCharacteristic];
}


- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    
    [self.cbService.peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *yc = self.characteristicDict[cname];
    [self.cbService.peripheral writeValue:data forCharacteristic:yc.cbCharacteristic type:type];
}

- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *yc = self.characteristicDict[cname];
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self.cbService.peripheral writeValue:data forCharacteristic:yc.cbCharacteristic type:type];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    [self.cbService.peripheral readValueForCharacteristic:characteristic];
    
}

- (void)readValueForCharacteristicName:(NSString *)cname {
    YMSCBCharacteristic *yc = self.characteristicDict[cname];
    [self.cbService.peripheral readValueForCharacteristic:yc.cbCharacteristic];
}


- (void)requestConfig {
    [self readValueForCharacteristicName:@"config"];
    //[self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
}

- (NSData *)responseConfig {
    YMSCBCharacteristic *yc = self.characteristicDict[@"config"];
    NSData *data = yc.cbCharacteristic.value;
    return data;
}

- (void)turnOff {
    [self writeByte:0x0 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:NO forCharacteristicName:@"data"];
    self.isOn = NO;
}

- (void)turnOn {
    [self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:YES forCharacteristicName:@"data"];
    self.isOn = YES;
}

- (void)updateCharacteristic:(YMSCBCharacteristic *)yc {
    // OVERRIDE THIS METHOD
}

@end
