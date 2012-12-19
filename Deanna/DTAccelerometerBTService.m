//
//  DTAccelerometerBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTAccelerometerBTService.h"
#import "DTCharacteristic.h"

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
    [(DTCharacteristic *)(self.characteristicMap[@"data"]) uuid],
    [(DTCharacteristic *)(self.characteristicMap[@"config"]) uuid],
    [(DTCharacteristic *)(self.characteristicMap[@"period"]) uuid]
    ];
    
    return result;
}


- (void)updateAcceleration {
    DTCharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    int16_t xx = val[0];
    int16_t yy = val[1];
    int16_t zz = val[2];
    
    
    self.x = [NSNumber numberWithInt:xx];
    self.y = [NSNumber numberWithInt:yy];
    self.z = [NSNumber numberWithInt:zz];
}



@end
