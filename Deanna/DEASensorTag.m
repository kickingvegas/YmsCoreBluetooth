//
//  DEASensorTag.m
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEASensorTag.h"
#import "DEATemperatureService.h"
#import "DEASimpleKeysService.h"
#import "DEAAccelerometerService.h"
#import "YMSCBCharacteristic.h"

@implementation DEASensorTag

- (id)initWithPeripheral:(CBPeripheral *)peripheral
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update {
    
    self = [super initWithPeripheral:peripheral baseHi:hi baseLo:lo updateRSSI:update];
    
    if (self) {
        
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature"];
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer"];
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys"];
        [sks turnOn];
        
        self.serviceDict = @{@"temperature": ts,
                             @"accelerometer": as,
                             @"simplekeys": sks};
        
    }
    return self;

}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    [super peripheral:peripheral didDiscoverCharacteristicsForService:service error:&*error];
    
    YMSCBService *btService = [self findService:service];

    if ([btService.name isEqualToString:@"simplekeys"]) {
        [btService setNotifyValue:YES forCharacteristicName:@"data"];
    }
    else {
        [btService requestConfig];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:&*error];

    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *dtc = [btService findCharacteristic:characteristic];
    
    if ([dtc.name isEqualToString:@"config"]) {
        
        // TODO: need to handle this
        /*
         NSData *data = [btService responseConfig];
         
         if ([YMSCBUtils dataToByte:data] == 0x1) {
         btService.isEnabled = YES;
         }
         else {
         btService.isEnabled = NO;
         }
         */
    }
    
}


@end
