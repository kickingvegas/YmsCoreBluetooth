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


#import "DEACentralManager.h"
#import "DEASensorTag.h"
#import "YMSCBStoredPeripherals.h"
#include "TISensorTag.h"


#define CALLBACK_EXAMPLE 1

static DEACentralManager *sharedCentralManager;

@implementation DEACentralManager


+ (DEACentralManager *)sharedService {
    if (sharedCentralManager == nil) {
        NSArray *nameList = @[@"TI BLE Sensor Tag", @"SensorTag"];
        sharedCentralManager = [[super allocWithZone:NULL] initWithKnownPeripheralNames:nameList
                                                                                queue:nil
                                                                 useStoredPeripherals:YES];
    }
    return sharedCentralManager;
}


- (void)startScan {
    NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
    // TODO: Don't know what service UUIDs are required to work with TI SensorTag.
    // NSArray *services = @[[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]];
    
    
    /*
     Note that in this implementation, handleFoundPeripheral: is implemented so that it can be used via block callback or as a
     delagate handler method. This is an implementation specific decision to handle discovered and retrieved peripherals identically.

     This may not always be the case, where for example information from advertisementData and the RSSI are to be factored in.
     */
    
#ifdef CALLBACK_EXAMPLE
    [self scanForPeripheralsWithServices:nil
                                 options:options
                               withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                   if (error) {
                                       NSLog(@"Something bad happened with scanForPeripheralWithServices:options:withBlock:");
                                       return;
                                   }
                                   
                                   NSLog(@"DISCOVERED: %@, %@, %@ db", peripheral, peripheral.name, RSSI);
                                   [self handleFoundPeripheral:peripheral];
                               }];
    
#else
    [self scanForPeripheralsWithServices:nil options:options];
#endif

}

- (void)handleFoundPeripheral:(CBPeripheral *)peripheral {
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    if (yp == nil) {
        BOOL isUnknownPeripheral = YES;
        for (NSString *pname in self.knownPeripheralNames) {
            if ([pname isEqualToString:peripheral.name]) {
                DEASensorTag *sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral
                                                                           central:self
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
            yp = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral central:self baseHi:0 baseLo:0 updateRSSI:NO];
            [self.ymsPeripherals addObject:yp];
        }
    }

}

- (void)connect:(YMSCBPeripheral *)peripheral  {
    [self connectPeripheral:peripheral
                    options:nil
                  withBlock:^(YMSCBPeripheral *yp, NSError *error) {
                      if (error) {
                          NSLog(@"Something bad happened with connectPeripheral:options:withBlock:");
                          return;
                      }
                      [peripheral discoverServices];
                  }];
}

- (void)managerPoweredOnHandler {
    if (self.useStoredPeripherals) {
        NSArray *peripheralUUIDs = [YMSCBStoredPeripherals genPeripheralUUIDs];

        [self retrievePeripherals:peripheralUUIDs
                        withBlock:^(CBPeripheral *peripheral) {
                            [self handleFoundPeripheral:peripheral];
                        }];
    }
}



@end
