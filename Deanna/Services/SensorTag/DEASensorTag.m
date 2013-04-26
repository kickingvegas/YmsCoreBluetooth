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
#import "DEAMagnetometerService.h"
#import "YMSCBCharacteristic.h"

@implementation DEASensorTag

- (id)initWithPeripheral:(CBPeripheral *)peripheral
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update {
    
    self = [super initWithPeripheral:peripheral baseHi:hi baseLo:lo updateRSSI:update];
    
    if (self) {
        
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature" baseHi:hi baseLo:lo];
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer" baseHi:hi baseLo:lo];
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys" baseHi:hi baseLo:lo];
        DEAHumidityService *hs = [[DEAHumidityService alloc] initWithName:@"humidity" baseHi:hi baseLo:lo];
        DEABarometerService *bs = [[DEABarometerService alloc] initWithName:@"barometer" baseHi:hi baseLo:lo];
        DEAGyroscopeService *gs = [[DEAGyroscopeService alloc] initWithName:@"gyroscope" baseHi:hi baseLo:lo];
        DEAMagnetometerService *ms = [[DEAMagnetometerService alloc] initWithName:@"magnetometer" baseHi:hi baseLo:lo];
        
        self.serviceDict = @{@"temperature": ts,
                             @"accelerometer": as,
                             @"simplekeys": sks,
                             @"humidity": hs,
                             @"magnetometer": ms,
                             @"gyroscope": gs,
                             @"barometer": bs};

        [sks turnOn];
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


@end
