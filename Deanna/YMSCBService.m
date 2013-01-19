//
//  DTSensorBTService.m
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
    YMSCBCharacteristic *dtc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntOffset:addrOffset];
    
    dtc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addrOffset];
    
    [self.characteristicMap setObject:dtc forKey:cname];
}

- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr {
    
    YMSCBCharacteristic *dtc;
    NSString *addrString = [NSString stringWithFormat:@"%x", addr];
    
    
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    dtc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addr];
    
    [self.characteristicMap setObject:dtc forKey:cname];
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
        YMSCBCharacteristic *dtc = self.characteristicMap[key];
        for (CBCharacteristic *ct in foundCharacteristics) {
            if ([dtc.uuid isEqual:ct.UUID]) {
                dtc.characteristic = ct;
                break;
            }
        }
    }
}

- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct {
    YMSCBCharacteristic *result;
    for (NSString *key in self.characteristicMap) {
        YMSCBCharacteristic *dtc = self.characteristicMap[key];
            
        if ([dtc.characteristic.UUID isEqual:ct.UUID]) {
            result = dtc;
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
    YMSCBCharacteristic *dtc = self.characteristicMap[cname];
    [self.cbService.peripheral setNotifyValue:notifyValue forCharacteristic:dtc.characteristic];
}


- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    
    [self.cbService.peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *dtc = self.characteristicMap[cname];
    [self.cbService.peripheral writeValue:data forCharacteristic:dtc.characteristic type:type];
}

- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    YMSCBCharacteristic *dtc = self.characteristicMap[cname];
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self.cbService.peripheral writeValue:data forCharacteristic:dtc.characteristic type:type];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    [self.cbService.peripheral readValueForCharacteristic:characteristic];
    
}

- (void)readValueForCharacteristicName:(NSString *)cname {
    YMSCBCharacteristic *dtc = self.characteristicMap[cname];
    [self.cbService.peripheral readValueForCharacteristic:dtc.characteristic];
}


- (void)requestConfig {
    [self readValueForCharacteristicName:@"config"];
    //[self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
}

- (NSData *)responseConfig {
    YMSCBCharacteristic *dtc = self.characteristicMap[@"config"];
    NSData *data = dtc.characteristic.value;
    return data;
}

- (void)turnOff {
    [self writeByte:0x0 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:NO forCharacteristicName:@"data"];
}

- (void)turnOn {
    [self writeByte:0x1 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:YES forCharacteristicName:@"data"];
}


- (void)update {
    // To override
}

@end
