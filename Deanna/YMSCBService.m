//
//  YMSCBService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"
#import "YMSCBUtils.h"
#import "YMSCBCharacteristic.h"


@implementation YMSCBService


- (id)init {
    self = [super init];
    
    if (self) {
        _characteristicMap = [[NSMutableDictionary alloc] init];
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
    
    [self.characteristicMap setObject:yc forKey:cname];
}

- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr {
    
    YMSCBCharacteristic *yc;
    NSString *addrString = [NSString stringWithFormat:@"%x", addr];
    
    
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addr];
    
    [self.characteristicMap setObject:yc forKey:cname];
}



- (NSArray *)characteristics {
    
    NSArray *result = @[
    [(YMSCBCharacteristic *)(self.characteristicMap[@"data"]) uuid],
    [(YMSCBCharacteristic *)(self.characteristicMap[@"config"]) uuid],
    ];

    return result;
}


- (void)syncCharacteristics:(NSArray *)foundCharacteristics {
    for (NSString *key in self.characteristicMap) {
        YMSCBCharacteristic *yc = self.characteristicMap[key];
        for (CBCharacteristic *ct in foundCharacteristics) {
            if ([yc.uuid isEqual:ct.UUID]) {
                yc.characteristic = ct;
                break;
            }
        }
    }
    
    self.isEnabled = YES;
}

- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct {
    YMSCBCharacteristic *result;
    for (NSString *key in self.characteristicMap) {
        YMSCBCharacteristic *yc = self.characteristicMap[key];
            
        if ([yc.characteristic.UUID isEqual:ct.UUID]) {
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
    YMSCBCharacteristic *yc = self.characteristicMap[cname];
    [self.cbService.peripheral setNotifyValue:notifyValue forCharacteristic:yc.characteristic];
}


- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    
    [self.cbService.peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *yc = self.characteristicMap[cname];
    [self.cbService.peripheral writeValue:data forCharacteristic:yc.characteristic type:type];
}

- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *yc = self.characteristicMap[cname];
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self.cbService.peripheral writeValue:data forCharacteristic:yc.characteristic type:type];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    [self.cbService.peripheral readValueForCharacteristic:characteristic];
    
}

- (void)readValueForCharacteristicName:(NSString *)cname {
    YMSCBCharacteristic *yc = self.characteristicMap[cname];
    [self.cbService.peripheral readValueForCharacteristic:yc.characteristic];
}


- (void)requestConfig {
    [self readValueForCharacteristicName:@"config"];
    //[self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
}

- (NSData *)responseConfig {
    YMSCBCharacteristic *yc = self.characteristicMap[@"config"];
    NSData *data = yc.characteristic.value;
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


- (void)update {
    // To override
}

@end
