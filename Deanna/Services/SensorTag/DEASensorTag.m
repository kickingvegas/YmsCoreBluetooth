// 
// Copyright 2013-2014 Yummy Melon Software LLC
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
#import "DEAAccelerometerService.h"
#import "DEABarometerService.h"
#import "DEADeviceInfoService.h"
#import "DEAGyroscopeService.h"
#import "DEAHumidityService.h"
#import "DEAMagnetometerService.h"
#import "DEASimpleKeysService.h"
#import "DEATemperatureService.h"
#import "YMSCBCharacteristic.h"
#import "YMSCBDescriptor.h"
#import "TISensorTag.h"


@implementation DEASensorTag

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                           central:(YMSCBCentralManager *)owner
                            baseHi:(int64_t)hi
                            baseLo:(int64_t)lo {

    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo];
    
    if (self) {
        DEATemperatureService *ts = [[DEATemperatureService alloc] initWithName:@"temperature" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_TEMPERATURE_SERVICE];
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_ACCELEROMETER_SERVICE];
        DEASimpleKeysService *sks = [[DEASimpleKeysService alloc] initWithName:@"simplekeys" parent:self baseHi:0 baseLo:0 serviceOffset:kSensorTag_SIMPLEKEYS_SERVICE];
        DEAHumidityService *hs = [[DEAHumidityService alloc] initWithName:@"humidity" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_HUMIDITY_SERVICE];
        DEABarometerService *bs = [[DEABarometerService alloc] initWithName:@"barometer" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_BAROMETER_SERVICE];
        DEAGyroscopeService *gs = [[DEAGyroscopeService alloc] initWithName:@"gyroscope" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_GYROSCOPE_SERVICE];
        DEAMagnetometerService *ms = [[DEAMagnetometerService alloc] initWithName:@"magnetometer" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_MAGNETOMETER_SERVICE];
        DEADeviceInfoService *ds = [[DEADeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:0 baseLo:0 serviceOffset:kSensorTag_DEVINFO_SERV_UUID];
        
        self.serviceDict = @{@"temperature": ts,
                             @"accelerometer": as,
                             @"simplekeys": sks,
                             @"humidity": hs,
                             @"magnetometer": ms,
                             @"gyroscope": gs,
                             @"barometer": bs,
                             @"devinfo": ds};
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
        
        // Example where only a subset of services is to be discovered.
        //[yp discoverServices:[yp servicesSubset:@[@"temperature", @"simplekeys", @"devinfo"]] withBlock:^(NSArray *yservices, NSError *error) {
        
        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                return;
            }
            
            for (YMSCBService *service in yservices) {
                if ([service.name isEqualToString:@"simplekeys"]) {
                    __weak DEASimpleKeysService *thisService = (DEASimpleKeysService *)service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService turnOn];
                    }];
                    
                } else if ([service.name isEqualToString:@"devinfo"]) {
                    __weak DEADeviceInfoService *thisService = (DEADeviceInfoService *)service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readDeviceInfo];
                    }];
                    
                } else {
                    __weak DEABaseService *thisService = (DEABaseService *)service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        for (NSString *key in chDict) {
                            YMSCBCharacteristic *ct = chDict[key];
                            //NSLog(@"%@ %@ %@", ct, ct.cbCharacteristic, ct.uuid);
                            
                            [ct discoverDescriptorsWithBlock:^(NSArray *ydescriptors, NSError *error) {
                                if (error) {
                                    return;
                                }
                                for (YMSCBDescriptor *yd in ydescriptors) {
                                    NSLog(@"Descriptor: %@ %@ %@", thisService.name, yd.UUID, yd.cbDescriptor);
                                }
                            }];
                        }
                    }];
                }
            }
        }];
    }];
}


- (DEAAccelerometerService *)accelerometer {
    return self.serviceDict[@"accelerometer"];
}

- (DEABarometerService *)barometer {
    return self.serviceDict[@"barometer"];
}

- (DEADeviceInfoService *)devinfo {
    return self.serviceDict[@"devinfo"];
}

- (DEAGyroscopeService *)gyroscope {
    return self.serviceDict[@"gyroscope"];
}

- (DEAHumidityService *)humidity {
    return self.serviceDict[@"humidity"];
}

- (DEAMagnetometerService *)magnetometer {
    return self.serviceDict[@"magnetometer"];
}

- (DEASimpleKeysService *)simplekeys {
    return self.serviceDict[@"simplekeys"];
}

- (DEATemperatureService *)temperature {
    return self.serviceDict[@"temperature"];
}

@end
