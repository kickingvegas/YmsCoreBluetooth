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


#import "DEACentralManager.h"
#import "DEASensorTag.h"
#import "YMSCBStoredPeripherals.h"
#include "TISensorTag.h"


#define CALLBACK_EXAMPLE 1

static DEACentralManager *sharedCentralManager;

@implementation DEACentralManager

+ (DEACentralManager *)initSharedServiceWithDelegate:(id)delegate {
    if (sharedCentralManager == nil) {
        dispatch_queue_t queue = dispatch_queue_create("com.yummymelon.deanna", 0);

        NSArray *nameList = @[@"TI BLE Sensor Tag", @"SensorTag"];
        sharedCentralManager = [[super allocWithZone:NULL] initWithKnownPeripheralNames:nameList
                                                                                  queue:queue
                                                                   useStoredPeripherals:YES
                                                                               delegate:delegate];
    }
    return sharedCentralManager;
    
}


+ (DEACentralManager *)sharedService {
    if (sharedCentralManager == nil) {
        NSLog(@"ERROR: must call initSharedServiceWithDelegate: first.");
    }
    return sharedCentralManager;
}


- (void)startScan {
    /*
     Setting CBCentralManagerScanOptionAllowDuplicatesKey to YES will allow for repeated updates of the RSSI via advertising.
     */
    
    NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
    // NOTE: TI SensorTag firmware does not included services in advertisementData.
    // This prevents usage of serviceUUIDs array to filter on.

    /*
     Note that in this implementation, handleFoundPeripheral: is implemented so that it can be used via block callback or as a
     delagate handler method. This is an implementation specific decision to handle discovered and retrieved peripherals identically.

     This may not always be the case, where for example information from advertisementData and the RSSI are to be factored in.
     */
    
#ifdef CALLBACK_EXAMPLE
    __weak DEACentralManager *this = self;
    [self scanForPeripheralsWithServices:nil
                                 options:options
                               withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                   if (error) {
                                       NSLog(@"Something bad happened with scanForPeripheralWithServices:options:withBlock:");
                                       return;
                                   }
                                   
                                   NSLog(@"DISCOVERED: %@, %@, %@ db", peripheral, peripheral.name, RSSI);
                                   [this handleFoundPeripheral:peripheral];
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
                                                                            baseLo:kSensorTag_BASE_ADDRESS_LO];

                [self addPeripheral:sensorTag];
                isUnknownPeripheral = NO;
                break;
                
            }
            
        }
        
        if (isUnknownPeripheral) {
            //TODO: Handle unknown peripheral
            yp = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral central:self baseHi:0 baseLo:0];
            [self addPeripheral:yp];
        }
    }

}


- (void)managerPoweredOnHandler {
    // TODO: Determine if peripheral retrieval works on stock Macs with BLE support.
    /* 
       Using iMac with Cirago BLE USB adapter, retreival with return a CBPeripheral instance without properties 
       correctly populated such as name. This behavior is not exhibited when running on iOS.
     */
    
    if (self.useStoredPeripherals) {
#if TARGET_OS_IPHONE
        NSArray *identifiers = [YMSCBStoredPeripherals genIdentifiers];
        [self retrievePeripheralsWithIdentifiers:identifiers];
#endif
    }
}



@end
