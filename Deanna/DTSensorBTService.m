//
//  DTSensorBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTSensorBTService.h"
#import "YMSCBUtils.h"
#import "DTCharacteristic.h"

@implementation DTSensorBTService


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
    DTCharacteristic *dtc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntOffset:addrOffset];
    
    dtc = [[DTCharacteristic alloc] initWithName:cname
                                            uuid:uuid
                                          offset:addrOffset];
    
    [self.characteristicMap setObject:dtc forKey:cname];
}



- (NSArray *)characteristics {
    
    NSArray *result = @[
    [(DTCharacteristic *)(self.characteristicMap[@"data"]) uuid],
    [(DTCharacteristic *)(self.characteristicMap[@"config"]) uuid],
    ];

    return result;
}


- (void)syncCharacteristics:(NSArray *)foundCharacteristics {
    for (NSString *key in self.characteristicMap) {
        DTCharacteristic *dtc = self.characteristicMap[key];
        for (CBCharacteristic *ct in foundCharacteristics) {
            if ([dtc.uuid isEqual:ct.UUID]) {
                dtc.characteristic = ct;
                break;
            }
        }
    }
}

- (DTCharacteristic *)findCharacteristic:(CBCharacteristic *)ct {
    DTCharacteristic *result;
    for (NSString *key in self.characteristicMap) {
        DTCharacteristic *dtc = self.characteristicMap[key];
            
        if ([dtc.characteristic.UUID isEqual:ct.UUID]) {
            result = dtc;
            break;
        }
    }
    return result;
}


- (void)setNotifyValue:(BOOL)notifyValue forCharacteristic:(CBCharacteristic *)characteristic {
    [self.service.peripheral setNotifyValue:notifyValue
                          forCharacteristic:characteristic];
    
}

- (void)setNotifyValue:(BOOL)notifyValue forCharacteristicName:(NSString *)cname {
    DTCharacteristic *dtc = self.characteristicMap[cname];
    [self.service.peripheral setNotifyValue:notifyValue forCharacteristic:dtc.characteristic];
}


- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    
    [self.service.peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    DTCharacteristic *dtc = self.characteristicMap[cname];
    [self.service.peripheral writeValue:data forCharacteristic:dtc.characteristic type:type];
}

- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type {
    DTCharacteristic *dtc = self.characteristicMap[cname];
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self.service.peripheral writeValue:data forCharacteristic:dtc.characteristic type:type];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    [self.service.peripheral readValueForCharacteristic:characteristic];
    
}

- (void)readValueForCharacteristicName:(NSString *)cname {
    DTCharacteristic *dtc = self.characteristicMap[cname];
    [self.service.peripheral readValueForCharacteristic:dtc.characteristic];
}


@end
