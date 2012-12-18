//
//  DTAccelerometerConfig.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTAccelerometerConfig.h"

@implementation DTAccelerometerConfig


- (id)initWithBase:(yms_u128_t *)base {
    self = [super init];
    
    if (self) {
        self.name = @"accelerometer";
        self.service = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_ACCELEROMETER_SERVICE];
        self.data = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_ACCELEROMETER_DATA];
        self.config = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_ACCELEROMETER_CONFIG];
        _period = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_ACCELEROMETER_PERIOD];
    }
    return self;
    
}


- (NSArray *)genCharacteristics {
    NSArray *result = @[
    [CBUUID UUIDWithString:self.data],
    [CBUUID UUIDWithString:self.config],
    [CBUUID UUIDWithString:self.period]
    ];
    
    return result;
}

@end
