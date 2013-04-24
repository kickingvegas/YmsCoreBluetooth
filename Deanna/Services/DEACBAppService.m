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



- (void)startScan {
    NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
    // TODO: Don't know what service UUIDs are required to work with TI SensorTag.
    //NSArray *services = @[[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]];

    [self scanForPeripheralsWithServices:nil options:options];
}


- (void)handleFoundPeripheral:(CBPeripheral *)peripheral {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];

    if (yp == nil) {
        BOOL isUnknownPeripheral = YES;
        for (NSString *pname in self.peripheralSearchNames) {
            if ([pname isEqualToString:peripheral.name]) {
                DEASensorTag *sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral
                                                                            baseHi:kSensorTag_BASE_ADDRESS_HI
                                                                            baseLo:kSensorTag_BASE_ADDRESS_LO
                                                                        updateRSSI:YES];
                [self.ymsPeripherals addObject:sensorTag];
                isUnknownPeripheral = NO;
                break;
                
            }
            
        }
        
        if (isUnknownPeripheral) {
            //TODO: Handle unknown peripheral
            yp = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral baseHi:0 baseLo:0 updateRSSI:NO];
            [self.ymsPeripherals addObject:yp];
        }
    }
    
}



@end
