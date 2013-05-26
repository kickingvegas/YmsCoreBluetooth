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

#import "YMSCBCharacteristic.h"
#import "NSMutableArray+fifoQueue.h"
#import "YMSCBPeripheral.h"

@implementation YMSCBCharacteristic


- (id)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj uuid:(CBUUID *)oUUID offset:(int)addrOffset {

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
        self.notificationStateCallback = notifyStateCallback;
    }
    [self.parent.cbPeripheral setNotifyValue:notifyValue forCharacteristic:self.cbCharacteristic];
}

- (void)executeNotificationStateCallback:(NSError *)error {
    if (self.notificationStateCallback) {
        self.notificationStateCallback(error);
        self.notificationStateCallback = nil;
    }
}


- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *))writeCallback {
    if (writeCallback) {
        [self.writeCallbacks push:writeCallback];
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
    [self.readCallbacks push:readCallback];
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




@end
