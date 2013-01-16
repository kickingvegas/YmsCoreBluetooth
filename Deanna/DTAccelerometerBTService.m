//
//  DTAccelerometerBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTAccelerometerBTService.h"
#import "DEACharacteristic.h"


float calcAccel(int16_t rawV) {
    float v;
    v = ((float)rawV + 1.0) / (256.0/4.0);
    return v;
}

@implementation DTAccelerometerBTService


- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_ACCELEROMETER_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_ACCELEROMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_ACCELEROMETER_CONFIG];
        [self addCharacteristic:@"period" withOffset:kSensorTag_ACCELEROMETER_PERIOD];
    }
    return self;
}

- (NSArray *)characteristics {
    
    NSArray *result = @[
    [(DEACharacteristic *)(self.characteristicMap[@"data"]) uuid],
    [(DEACharacteristic *)(self.characteristicMap[@"config"]) uuid],
    [(DEACharacteristic *)(self.characteristicMap[@"period"]) uuid]
    ];
    
    return result;
}


- (void)updateAcceleration {
    DEACharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    int16_t xx = val[0];
    int16_t yy = val[1];
    int16_t zz = val[2];
    
    
    self.x = [NSNumber numberWithFloat:calcAccel(xx)];
    self.y = [NSNumber numberWithFloat:calcAccel(yy)];
    self.z = [NSNumber numberWithFloat:calcAccel(zz)];
}



@end
