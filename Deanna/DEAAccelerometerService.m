//
//  DTAccelerometerBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEAAccelerometerService.h"
#import "YMSCBCharacteristic.h"


float calcAccel(int16_t rawV) {
    float v;
    v = ((float)rawV + 1.0) / (256.0/4.0);
    return v;
}

@implementation DEAAccelerometerService


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
    [(YMSCBCharacteristic *)(self.characteristicMap[@"data"]) uuid],
    [(YMSCBCharacteristic *)(self.characteristicMap[@"config"]) uuid],
    [(YMSCBCharacteristic *)(self.characteristicMap[@"period"]) uuid]
    ];
    
    return result;
}


- (void)update {
    YMSCBCharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.cbCharacteristic.value;
    
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
