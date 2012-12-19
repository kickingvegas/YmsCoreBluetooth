//
//  DTTemperatureBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTTemperatureBTService.h"
#import "DTCharacteristic.h"

@implementation DTTemperatureBTService

- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_TEMPERATURE_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_TEMPERATURE_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_TEMPERATURE_CONFIG];
    }
    return self;
}

- (void)updateTemperature {
    DTCharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    
    int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
    
    int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));
    
    self.ambientTemp = [NSNumber numberWithInt:amb];
    self.objectTemp = [NSNumber numberWithInt:objT];

}

@end
