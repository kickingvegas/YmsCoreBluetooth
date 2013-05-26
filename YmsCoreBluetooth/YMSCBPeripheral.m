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

#import "YMSCBCentralManager.h"
#import "YMSCBPeripheral.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"



@implementation YMSCBPeripheral

- (id)initWithPeripheral:(CBPeripheral *)peripheral
                 central:(YMSCBCentralManager *)owner
                  baseHi:(int64_t)hi
                  baseLo:(int64_t)lo
              updateRSSI:(BOOL)update {
    
    self = [super init];
    
    if (self) {
        _central = owner;
        _base.hi = hi;
        _base.lo = lo;
        
        _cbPeripheral = peripheral;
        peripheral.delegate = self;
        
        _rssiPingPeriod = 2.0;

        _willPingRSSI = update;
        if (update == YES) {
            [peripheral readRSSI];
        }
        
        //_peripheralConnectionState = YMSCBPeripheralConnectionStateUnknown;
        _watchdogTimerInterval = 5.0;
    }

    return self;
}


#pragma mark - Peripheral Methods

- (BOOL)isConnected {
    return self.cbPeripheral.isConnected;
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *service = self.serviceDict[key];
        YMSCBCharacteristic *ct = service.characteristicDict[@"service"];
        
        [tempArray addObject:ct.uuid];
    }
    
    result = tempArray;
    return result;
}

- (YMSCBService *)findService:(CBService *)service {
    YMSCBService *result;
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *btService = self.serviceDict[key];
        YMSCBCharacteristic *ct = btService.characteristicDict[@"service"];
        
        if ([service.UUID isEqual:ct.uuid]) {
            result = btService;
            break;
        }
        
    }
    return result;
}

- (void)updateRSSI {
    [self.cbPeripheral readRSSI];
    
}


- (void)discoverServices {
    NSArray *services = [self services];
    [self.cbPeripheral discoverServices:services];
}



#pragma mark - Connection Methods

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
                    // TODO find descriptors (if necessary)

                }];
                
            }
            
        }];
    }];
}


- (void)disconnect {
    // Watchdog aware method
    if (self.watchdogTimer) {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
    }

    [self cancelConnection];
}

- (void)resetWatchdog {
    if (self.watchdogTimer) {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
    }

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.watchdogTimerInterval
                                                      target:self
                                                    selector:@selector(watchdogDisconnect)
                                                    userInfo:nil
                                                     repeats:NO];
    self.watchdogTimer = timer;
}


- (void)watchdogDisconnect {
    // Watchdog aware method
    if (!self.isConnected) {
        [self disconnect];
    }
    self.watchdogTimer = nil;
    
}

- (void)connectWithOptions:(NSDictionary *)options withBlock:(void (^)(YMSCBPeripheral *, NSError *))connectCallback {
    self.connectCallback = connectCallback;
    [self.central.manager connectPeripheral:self.cbPeripheral options:options];
}


- (void)cancelConnection {
    if (self.connectCallback) {
        self.connectCallback = nil;
    }
    [self.central.manager cancelPeripheralConnection:self.cbPeripheral];
}


- (void)handleConnectionResponse:(NSError *)error {
    if (self.connectCallback) {
        self.connectCallback(self, error);
        self.connectCallback = nil;
    } else {
        // TODO: support connectionHandler
        [self defaultConnectionHandler];
    }
}

- (void)defaultConnectionHandler {
    NSAssert(NO, @"[YMSCBPeripheral defaultConnectionHandler] must be overridden if connectCallback is nil.");
}

#pragma mark - Services Discovery

- (void)discoverServices:(NSArray *)serviceUUIDs withBlock:(void (^)(NSArray *, NSError *))callback {
    self.discoverServicesCallback = callback;
    
    [self.cbPeripheral discoverServices:serviceUUIDs];
}




#pragma mark - CBPeripheralDelegate Methods

/** @name CBPeripheralDelegate Methods */
/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral that the services belong to.
 @param error If an error occurred, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (self.discoverServicesCallback) {
        NSMutableArray *services = [NSMutableArray new];
        
        // TODO: add method syncServices
        for (CBService *service in peripheral.services) {
            YMSCBService *btService = [self findService:service];
            if (btService) {
                btService.cbService = service;
                [services addObject:btService];
            }
        }
        
        self.discoverServicesCallback(services, error);
        self.discoverServicesCallback = nil;
    }
}



/**
 CBPeripheralDelegate implementation.  Not yet supported.

 @param peripheral The peripheral providing this information.
 @param service The CBService object containing the included service.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    // TBD
}



/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param service The service that the characteristics belong to.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    YMSCBService *btService = [self findService:service];
    
    [btService syncCharacteristics:service.characteristics];
    [btService handleDiscoveredCharacteristicsResponse:btService.characteristicDict withError:error];
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic that the characteristic descriptors belong to.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // TBD
}


/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
    
    if (yc.cbCharacteristic.isNotifying) {
        [btService notifyCharacteristicHandler:yc error:error];
        
    } else {
        if ([yc.readCallbacks count] > 0) {
            [yc executeReadCallback:characteristic.value error:error];
        }
    }
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param descriptor The characteristic descriptor whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    // TBD
}

/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // TODO: Implement callback block for notification change response.
    
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
    
    [ct executeNotificationStateCallback:error];
}




/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
    
    if ([yc.writeCallbacks count] > 0) {
        [yc executeWriteCallback:error];
    } else {
        // TODO is this dangerous?
        [btService notifyCharacteristicHandler:yc error:error];
    }
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param descriptor The characteristic descriptor whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    // TBD
}


/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.willPingRSSI) {
        [self performSelector:@selector(updateRSSI) withObject:self afterDelay:self.rssiPingPeriod];
    }
    
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 */

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    // TBD
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    // TBD
}




@end
