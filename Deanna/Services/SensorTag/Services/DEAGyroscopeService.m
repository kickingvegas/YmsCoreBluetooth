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

#import "DEAGyroscopeService.h"
#import "YMSCBCharacteristic.h"

float calcGyro(int16_t v, float c, int16_t d) {
    float result;
    
    result = (((float)v * d) / (65536/500.0)) - c;
    
    return result;
}

@implementation DEAGyroscopeService

- (id)initWithName:(NSString *)oName
            parent:(YMSCBPeripheral *)pObj
            baseHi:(int64_t)hi
            baseLo:(int64_t)lo {
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_GYROSCOPE_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_GYROSCOPE_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_GYROSCOPE_CONFIG];
        _lastPitch = 0.0;
        _lastRoll = 0.0;
        _lastYaw = 0.0;
        _cPitch = 0.0;
        _cRoll = 0.0;
        _cYaw = 0.0;
    }
    return self;
}

- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if (error) {
        return;
    }

    if ([yc.name isEqualToString:@"data"]) {
        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        uint16_t v0 = val[0];
        uint16_t v1 = val[1];
        uint16_t v2 = val[2];
        uint16_t v3 = val[3];
        uint16_t v4 = val[4];
        uint16_t v5 = val[5];
        
        uint16_t xx = yms_u16_build(v0, v1);
        uint16_t yy = yms_u16_build(v2, v3);
        uint16_t zz = yms_u16_build(v4, v5);
        
        self.lastRoll = calcGyro(zz, self.cRoll, 1);
        self.lastPitch = calcGyro(yy, self.cPitch, -1);
        self.lastYaw = calcGyro(xx, self.cYaw, 1);
        
        self.roll = [NSNumber numberWithFloat:self.lastRoll];
        self.pitch = [NSNumber numberWithFloat:self.lastPitch];
        self.yaw = [NSNumber numberWithFloat:self.lastYaw];
        
    } else if ([yc.name isEqualToString:@"config"]) {
//        NSData *data = yc.cbCharacteristic.value;
//        
//        char val[data.length];
//        [data getBytes:&val length:data.length];
        
    }

}


- (void)calibrate {
    self.cRoll = self.lastRoll;
    self.cPitch = self.lastPitch;
    self.cYaw = self.lastYaw;
}

- (void)turnOn {
    [self writeByte:0x7 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:YES forCharacteristicName:@"data"];
    self.isOn = YES;
}



@end
