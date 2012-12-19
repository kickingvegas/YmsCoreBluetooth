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



@end
