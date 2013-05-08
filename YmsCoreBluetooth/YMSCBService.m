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
#import "NSMutableArray+fifoQueue.h"




@implementation YMSCBService


- (id)initWithName:(NSString *)oName
            baseHi:(int64_t)hi
            baseLo:(int64_t)lo {
    self = [super init];
    if (self) {
        _name = oName;
        _base.hi = hi;
        _base.lo = lo;
        _characteristicDict = [[NSMutableDictionary alloc] init];
        _responseBlockDict = [[NSMutableDictionary alloc] init];
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
    if (yc == nil) {
        NSString *assertString = [NSString stringWithFormat:@"YMSCBCharacteristic name '%@' is not defined.", cname];
        NSAssert(NO, assertString);
    }

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
    if (yc == nil) {
        NSString *assertString = [NSString stringWithFormat:@"YMSCBCharacteristic name '%@' is not defined.", cname];
        NSAssert(NO, assertString);
    }
    
    [self.cbService.peripheral readValueForCharacteristic:yc.cbCharacteristic];
}


- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if (error) {
        return;
    }
}


- (void)readValueForCharacteristicName:(NSString *)cname withBlock:(void (^)(NSData *, NSError *))readCallback {
    
    if (self.responseBlockDict[cname] == nil) {
        self.responseBlockDict[cname] = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *responseBlockArray = (NSMutableArray *)self.responseBlockDict[cname];
    
    NSArray *payload = @[@(YMSCBReadCallbackType), readCallback];
    [responseBlockArray push:payload];
    [self readValueForCharacteristicName:cname];
}

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname withBlock:(void (^)(NSError *))writeCallback {
    
    if (self.responseBlockDict[cname] == nil) {
        self.responseBlockDict[cname] = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *responseBlockArray = (NSMutableArray *)self.responseBlockDict[cname];

    NSArray *payload = @[@(YMSCBWriteCallbackType), writeCallback];
    [responseBlockArray push:payload];
    [self writeValue:data forCharacteristicName:cname type:CBCharacteristicWriteWithResponse];
}


- (void)writeByte:(int8_t *)val forCharacteristicName:(NSString *)cname withBlock:(void (^)(NSError *))writeCallback {
    NSData *data = [NSData dataWithBytes:&val length:1];
    
    [self writeValue:data forCharacteristicName:cname withBlock:writeCallback];
}


- (void)executeBlock:(YMSCBCharacteristic *)yc error:(NSError *)error {
    
    if (error) {
        return;
    }
    
    NSMutableArray *responseBlockArray = (NSMutableArray *)self.responseBlockDict[yc.name];
    
    
    NSArray *payload = (NSArray *)[responseBlockArray pop];
    
    if (payload) {
        if ([payload count] == 2) {
            YMSCBCallbackTransactionType cbType = [(NSNumber *)payload[0] integerValue];
            switch (cbType) {
                case YMSCBWriteCallbackType: {
                    YMSCBWriteCallbackBlockType writeCB = payload[1];
                    writeCB(error);
                    break;
                }
                    
                case YMSCBReadCallbackType: {
                    YMSCBReadCallbackBlockType readCB = payload[1];
                    readCB(yc.cbCharacteristic.value, error);
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
}




@end
