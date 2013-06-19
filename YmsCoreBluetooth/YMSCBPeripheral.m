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
#import "YMSCBDescriptor.h"

@interface YMSCBPeripheral ()

- (void)performPeripheralDidDiscoverServicesWithObject:(NSArray *)args;
- (void)performPeripheralDidDiscoverIncludedServicesForServiceWithObject:(NSArray *)args;

- (void)performPeripheralDidDiscoverCharacteristicsForServiceWithObject:(NSArray *)args;
- (void)performPeripheralDidDiscoverDescriptorsForCharacteristicWithObject:(NSArray *)args;

- (void)performPeripheralDidUpdateValueForCharacteristicWithObject:(NSArray *)args;
- (void)performPeripheralDidUpdateValueForDescriptorWithObject:(NSArray *)args;

- (void)performPeripheralDidWriteValueForCharacteristicWithObject:(NSArray *)args;
- (void)performPeripheralDidWriteValueForDescriptorWithObject:(NSArray *)args;

- (void)performPeripheralDidUpdateNotificationStateForCharacteristicWithObject:(NSArray *)args;

- (void)performPeripheralDidUpdateRSSIWithObject:(NSArray *)args;

- (void)performPeripheralDidUpdateNameWithObject:(NSArray *)args;
- (void)performPeripheralDidInvalidateServicesWithObject:(NSArray *)args;

@end

@implementation YMSCBPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                           central:(YMSCBCentralManager *)owner
                            baseHi:(int64_t)hi
                            baseLo:(int64_t)lo {
    
    self = [super init];
    
    if (self) {
        _central = owner;
        _base.hi = hi;
        _base.lo = lo;
        
        _cbPeripheral = peripheral;
        peripheral.delegate = self;
        
        _rssiPingPeriod = 2.0;

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

#pragma mark - Connection Methods

- (void)connect {
    // Watchdog aware method
    [self resetWatchdog];

    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            return;
        }

        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                return;
            }
            
            for (YMSCBService *service in yservices) {
                __weak YMSCBService *thisService = (YMSCBService *)service;
                
                [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                    if (error) {
                        return;
                    }

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

- (void)performPeripheralDidDiscoverServicesWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    NSError *error = args[1];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didDiscoverServices:error];
}

- (void)performPeripheralDidDiscoverIncludedServicesForServiceWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBService *service = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didDiscoverIncludedServicesForService:service error:error];
}

- (void)performPeripheralDidDiscoverCharacteristicsForServiceWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBService *service = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
}

- (void)performPeripheralDidDiscoverDescriptorsForCharacteristicWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBCharacteristic *characteristic = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
}

- (void)performPeripheralDidUpdateValueForCharacteristicWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBCharacteristic *characteristic = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
}

- (void)performPeripheralDidUpdateValueForDescriptorWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBDescriptor *descriptor = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
}

- (void)performPeripheralDidWriteValueForCharacteristicWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBCharacteristic *characteristic = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

- (void)performPeripheralDidWriteValueForDescriptorWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBDescriptor *descriptor = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didWriteValueForDescriptor:descriptor error:error];
}

- (void)performPeripheralDidUpdateNotificationStateForCharacteristicWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    CBCharacteristic *characteristic = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
}

- (void)performPeripheralDidUpdateRSSIWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    NSError *error = args[1];
    if ((id)error == [NSNull null]) {
        error = nil;
    }
    [self.delegate peripheralDidUpdateRSSI:peripheral error:error];
}

- (void)performPeripheralDidUpdateNameWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    [self.delegate peripheralDidUpdateName:peripheral];
}

- (void)performPeripheralDidInvalidateServicesWithObject:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    [self.delegate peripheralDidInvalidateServices:peripheral];
}


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
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
        NSArray *args = @[peripheral, error];
        [self performSelectorOnMainThread:@selector(performPeripheralDidDiscoverServicesWithObject:) withObject:args waitUntilDone:NO];
    }
}



/**
 CBPeripheralDelegate implementation.  Not yet supported.

[self performSelectorOnMainThread:@selector(performPeripheralDidDiscoverIncludedServicesForServiceWithObject:) withObject:args waitUntilDone:NO]; @param peripheral The peripheral providing this information.
 @param service The CBService object containing the included service.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    // TBD
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)]) {

        NSArray *args;
        
        if (error) {
            args = @[peripheral, service, error];
        } else {
            args = @[peripheral, service, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performPeripheralDidDiscoverIncludedServicesForServiceWithObject:) withObject:args waitUntilDone:NO];
    }
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

    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
        NSArray *args;
        
        if (error) {
            args = @[peripheral, service, error];
        } else {
            args = @[peripheral, service, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performPeripheralDidDiscoverCharacteristicsForServiceWithObject:) withObject:args waitUntilDone:NO];
    }
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic that the characteristic descriptors belong to.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
    
    [ct syncDescriptors:characteristic.descriptors];
    [ct handleDiscoveredDescriptorsResponse:ct.descriptors withError:error];
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, characteristic, error];
        } else {
            args = @[peripheral, characteristic, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performPeripheralDidDiscoverDescriptorsForCharacteristicWithObject:) withObject:args waitUntilDone:NO];
    }
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
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, characteristic, error];
        } else {
            args = @[peripheral, characteristic, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performPeripheralDidUpdateValueForCharacteristicWithObject:) withObject:args waitUntilDone:NO];
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
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, descriptor, error];
        } else {
            args = @[peripheral, descriptor, [NSNull null]];
        }
        [self performSelectorOnMainThread:@selector(performPeripheralDidUpdateValueForDescriptorWithObject:) withObject:args waitUntilDone:NO];
    }
}

/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    YMSCBService *btService = [self findService:characteristic.service];
    YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
    
    [ct executeNotificationStateCallback:error];
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, characteristic, error];
        } else {
            args = @[peripheral, characteristic, [NSNull null]];
        }
        [self performSelectorOnMainThread:@selector(performPeripheralDidUpdateNotificationStateForCharacteristicWithObject:) withObject:args waitUntilDone:NO];
    }
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
    
    if ([self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, characteristic, error];
        } else {
            args = @[peripheral, characteristic, [NSNull null]];
        }
        [self performSelectorOnMainThread:@selector(performPeripheralDidWriteValueForCharacteristicWithObject:) withObject:args waitUntilDone:NO];
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
    if ([self.delegate respondsToSelector:@selector(peripheral:didWriteValueForDescriptor:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, descriptor, error];
        } else {
            args = @[peripheral, descriptor, [NSNull null]];
        }
        [self performSelectorOnMainThread:@selector(performPeripheralDidWriteValueForDescriptorWithObject:) withObject:args waitUntilDone:NO];
    }
}


/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    /*
    if (self.willPingRSSI) {
        [self performSelector:@selector(updateRSSI) withObject:nil afterDelay:self.rssiPingPeriod];
    }
     */
    
    if ([self.delegate respondsToSelector:@selector(peripheralDidUpdateRSSI:error:)]) {
        NSArray *args;
        if (error) {
            args = @[peripheral, error];
        } else {
            args = @[peripheral, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performPeripheralDidUpdateRSSIWithObject:) withObject:args waitUntilDone:NO];
    }
}


#if TARGET_OS_IPHONE
/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 iOS only.
 
 @param peripheral The peripheral providing this information.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    // TBD
    if ([self.delegate respondsToSelector:@selector(peripheralDidUpdateName:)]) {
        NSArray *args = @[peripheral];
        [self performSelectorOnMainThread:@selector(performPeripheralDidUpdateNameWithObject:) withObject:args waitUntilDone:NO];
    }

}
#endif

#if TARGET_OS_IPHONE
/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 iOS only.
 
 @param peripheral The peripheral providing this information.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    // TBD
    if ([self.delegate respondsToSelector:@selector(peripheralDidInvalidateServices:)]) {
        NSArray *args = @[peripheral];
        [self performSelectorOnMainThread:@selector(performPeripheralDidInvalidateServicesWithObject:) withObject:args waitUntilDone:NO];
    }
}
#endif


@end
