//
//  DEACBAppService.m
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEACBAppService.h"

static DEACBAppService *sharedCBAppService;

@implementation DEACBAppService


- (id)init {
    self = [super init];
    
    if (self) {
        self.peripheralSearchNames = @[@"TI BLE Sensor Tag", @"SensorTag"];
    }
    
    return self;
}


+ (DEACBAppService *)sharedService {
    if (sharedCBAppService == nil) {
        sharedCBAppService = [[super allocWithZone:NULL] init];
    }
    return sharedCBAppService;
}



@end
