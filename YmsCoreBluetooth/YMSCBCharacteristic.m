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

#import "YMSCBCharacteristic.h"
#import "NSMutableArray+fifoQueue.h"
#import "YMSCBPeripheral.h"
#import "YMSCBDescriptor.h"

@implementation YMSCBCharacteristic


- (instancetype)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj uuid:(CBUUID *)oUUID offset:(int)addrOffset {

    self = [super init];
    
    if (self) {
        _name = oName;
        _parent = pObj;
        _uuid = oUUID;
        _offset = [NSNumber numberWithInt:addrOffset];
        _writeCallbacks = [NSMutableArray new];
        _readCallbacks = [NSMutableArray new];
    }
    
    return self;
}


- (void)setNotifyValue:(BOOL)notifyValue withBlock:(void (^)(NSError *))notifyStateCallback {
    if (notifyStateCallback) {
        self.notificationStateCallback = [notifyStateCallback copy];
    }
    [self.parent.cbPeripheral setNotifyValue:notifyValue forCharacteristic:self.cbCharacteristic];
}

- (void)executeNotificationStateCallback:(NSError *)error {
    YMSCBWriteCallbackBlockType callback = self.notificationStateCallback;
    
    if (self.notificationStateCallback) {
        if (callback) {
            callback(error);
        } else {
            NSAssert(NO, @"ERROR: notificationStateCallback is nil; please check for multi-threaded access of executeNotificationStateCallback");
        }
        self.notificationStateCallback = nil;
    }
}


- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *))writeCallback {
    if (writeCallback) {
        [self.writeCallbacks push:[writeCallback copy]];
        [self.parent.cbPeripheral writeValue:data
                           forCharacteristic:self.cbCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
    } else {
        [self.parent.cbPeripheral writeValue:data
                           forCharacteristic:self.cbCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)writeByte:(int8_t)val withBlock:(void (^)(NSError *))writeCallback {
    NSData *data = [NSData dataWithBytes:&val length:1];
    [self writeValue:data withBlock:writeCallback];
}


- (void)readValueWithBlock:(void (^)(NSData *, NSError *))readCallback {
    [self.readCallbacks push:[readCallback copy]];
    [self.parent.cbPeripheral readValueForCharacteristic:self.cbCharacteristic];
}


- (void)executeReadCallback:(NSData *)data error:(NSError *)error {
    YMSCBReadCallbackBlockType readCB = [self.readCallbacks pop];
    readCB(data, error);
}

- (void)executeWriteCallback:(NSError *)error {
    YMSCBWriteCallbackBlockType writeCB = [self.writeCallbacks pop];
    writeCB(error);
}

- (void)discoverDescriptorsWithBlock:(void (^)(NSArray *, NSError *))callback {
    if (self.cbCharacteristic) {
        self.discoverDescriptorsCallback = callback;
    
        [self.parent.cbPeripheral discoverDescriptorsForCharacteristic:self.cbCharacteristic];
    } else {
        NSLog(@"WARNING: Attempt to discover descriptors with null cbCharacteristic: '%@' for %@", self.name, self.uuid);
    }
}


- (void)handleDiscoveredDescriptorsResponse:(NSArray *)ydescriptors withError:(NSError *)error {
    YMSCBDiscoverDescriptorsCallbackBlockType callback = [self.discoverDescriptorsCallback copy];

    if (callback) {
        callback(ydescriptors, error);
        self.discoverDescriptorsCallback = nil;
    } else {
        NSAssert(NO, @"ERROR: discoverDescriptorsCallback is nil; please check for multi-threaded access of handleDiscoveredDescriptorsResponse");
    }
}

- (void)syncDescriptors:(NSArray *)foundDescriptors {
    
    NSMutableArray *tempList = [[NSMutableArray alloc] initWithCapacity:[foundDescriptors count]];
    
    for (CBDescriptor *cbDescriptor in foundDescriptors) {
        YMSCBDescriptor *yd = [YMSCBDescriptor new];
        yd.cbDescriptor = cbDescriptor;
        yd.parent = self.parent;
        [tempList addObject:yd];
    }
    
    self.descriptors = tempList;
}

@end
