//
//  DTTemperatureService.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTTemperatureService.h"

@implementation DTTemperatureService


- (id)initWithBase:(yms_u128_t *)base {
    self = [super init];
    
    if (self) {
        self.name = @"temperature";
        self.service = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_TEMPERATURE_SERVICE];
        self.data = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_TEMPERATURE_DATA];
        self.config = [YMSCBUtils genCBUUID:base withIntOffset:kSensorTag_TEMPERATURE_CONFIG];
    }
    return self;

}

@end
