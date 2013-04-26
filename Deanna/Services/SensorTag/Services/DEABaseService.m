//
//  DEABaseService.m
//  Deanna
//
//  Created by Charles Choi on 4/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEABaseService.h"
#import "YMSCBCharacteristic.h"

@implementation DEABaseService

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


@end
