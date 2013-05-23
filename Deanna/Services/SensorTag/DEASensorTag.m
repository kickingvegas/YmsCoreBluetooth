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
#import "DEABaseService.h"
#import "DEATemperatureService.h"
#import "DEASimpleKeysService.h"
#import "DEAAccelerometerService.h"
#import "DEAHumidityService.h"
#import "DEABarometerService.h"
#import "DEAGyroscopeService.h"
#import "DEAMagnetometerService.h"
#import "DEADeviceInfoService.h"
#import "YMSCBCharacteristic.h"


@implementation DEASensorTag

- (id)initWithPeripheral:(CBPeripheral *)peripheral
                 central:(YMSCBCentralManager *)owner
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update {

    
    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo updateRSSI:update];
    
    if (self) {
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature" parent:self baseHi:hi baseLo:lo];
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer" parent:self baseHi:hi baseLo:lo];
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys" parent:self baseHi:hi baseLo:lo];
        DEAHumidityService *hs = [[DEAHumidityService alloc] initWithName:@"humidity" parent:self baseHi:hi baseLo:lo];
        DEABarometerService *bs = [[DEABarometerService alloc] initWithName:@"barometer" parent:self baseHi:hi baseLo:lo];
        DEAGyroscopeService *gs = [[DEAGyroscopeService alloc] initWithName:@"gyroscope" parent:self baseHi:hi baseLo:lo];
        DEAMagnetometerService *ms = [[DEAMagnetometerService alloc] initWithName:@"magnetometer" parent:self baseHi:hi baseLo:lo];
        DEADeviceInfoService *ds = [[DEADeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:hi baseLo:lo];
        
        self.serviceDict = @{@"temperature": ts,
                             @"accelerometer": as,
                             @"simplekeys": sks,
                             @"humidity": hs,
                             @"magnetometer": ms,
                             @"gyroscope": gs,
                             @"barometer": bs,
                             @"devinfo": ds};
        

        [sks turnOn];
    }
    return self;

}

- (void)connect {
    // Watchdog aware method
    [self resetWatchdog];
    
    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            return;
        }
        // NOTE: self and yp are the same.
        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                return;
            }
            
            for (YMSCBService *service in yservices) {
                [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                    if (error) {
                        return;
                    }
                    // TODO for find descriptors if necessary
                    
                    if ([service.name isEqualToString:@"simplekeys"]) {
                        [service setNotifyValue:YES forCharacteristicName:@"data"];

                    } else if ([service.name isEqualToString:@"devinfo"]) {
                        DEADeviceInfoService *ds = (DEADeviceInfoService *)service;
                        [ds readDeviceInfo];
                    }
                }];
                
            }
            
        }];
        
        
        
    }];
    
}


@end
