//
//  DTSensorConfig.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTSensorConfig.h"



@implementation DTSensorConfig

//- (NSString *)genCBUUIDString:(int)offsetConstant withBase:(yms_u128_t *)base {
//    yms_u128_t offset;
//    offset = yms_u128_genOffset(offsetConstant);
//    NSString *result = [YMSCBUtils genCBUUID:base withOffset:&offset];
//    
//    return result;
//}

- (id)initWithBase:(yms_u128_t *)base {
    // This method is to be overridden
    self = [super init];
    return self;
}


- (CBUUID *)genCBUUID:(NSString *)key {
    CBUUID *result = [CBUUID UUIDWithString:[self valueForKey:key]];
    return result;
}

- (NSArray *)genCharacteristics {
    NSArray *result = @[
    [CBUUID UUIDWithString:self.data],
    [CBUUID UUIDWithString:self.config]
    ];
    
    return result;
}


- (BOOL)isMatchToService:(CBService *)svc {
    BOOL result = NO;
    
    result = [svc.UUID isEqual:[CBUUID UUIDWithString:self.service]];
    
    return result;
}

- (BOOL)isMatchToCharacteristic:(CBCharacteristic *)ct withKey:(NSString *)key {
    BOOL result = NO;
    
    result = [ct.UUID isEqual:[self genCBUUID:key]];
    return result;
}

@end
