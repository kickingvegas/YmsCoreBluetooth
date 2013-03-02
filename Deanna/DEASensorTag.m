// 
// Copyright 2013 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//

#import "DEASensorTag.h"
#import "DEATemperatureService.h"
#import "DEASimpleKeysService.h"
#import "DEAAccelerometerService.h"
#import "DEAHumidityService.h"
#import "DEABarometerService.h"
#import "DEAGyroscopeService.h"
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
        
        DEAHumidityService *hs = [[DEAHumidityService alloc] initWithName:@"humidity"];
        DEABarometerService *bs = [[DEABarometerService alloc] initWithName:@"barometer"];
        DEAGyroscopeService *gs = [[DEAGyroscopeService alloc] initWithName:@"gyroscope"];

        
        self.serviceDict = @{@"temperature": ts,
                             @"accelerometer": as,
                             @"simplekeys": sks,
                             @"humidity": hs,
                             @"gyroscope": gs,
                             @"barometer": bs};
        
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
