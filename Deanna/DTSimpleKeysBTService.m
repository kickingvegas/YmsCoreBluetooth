//
//  DTSimpleKeysBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/20/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTSimpleKeysBTService.h"

@implementation DTSimpleKeysBTService


- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_SIMPLEKEYS_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_SIMPLEKEYS_DATA];
    }
    return self;
}

/*
- (void)updateTemperature {
    DTCharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    
    int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
    
    int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));
    
    double tempAmb = calcTmpLocal(amb);
    
    self.ambientTemp = [NSNumber numberWithDouble:tempAmb];
    self.objectTemp = [NSNumber numberWithDouble:calcTmpTarget(objT, tempAmb)];
    
}
*/
@end
