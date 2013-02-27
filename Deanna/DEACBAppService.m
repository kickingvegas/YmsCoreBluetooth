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


#import "DEACBAppService.h"
#import "DEASensorTag.h"

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


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central {
    
    DEASensorTag *sensorTag;
    
    [self stopScan];
    
    sensorTag = (DEASensorTag *)[self findYmsPeripheral:peripheral];
    
    if (sensorTag == nil) {
        sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral
                                                      baseHi:kSensorTag_BASE_ADDRESS_HI
                                                      baseLo:kSensorTag_BASE_ADDRESS_LO
                                                  updateRSSI:YES];

        [self.ymsPeripherals addObject:sensorTag];
        
        if (peripheral.isConnected == NO) {
            [central connectPeripheral:peripheral options:nil];
        }
    }
}



@end
