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

double calcGyro(int16_t v, int16_t d) {
    double result;
    
    result = (((double)v * d) / (65536/500.0));
    
    return result;
}

@implementation DEAGyroscopeService

- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_GYROSCOPE_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_GYROSCOPE_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_GYROSCOPE_CONFIG];
    }
    return self;
}

- (void)updateCharacteristic:(YMSCBCharacteristic *)yc {
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
        
        self.roll = [NSNumber numberWithFloat:calcGyro(zz, 1)];
        self.pitch = [NSNumber numberWithFloat:calcGyro(yy, -1)];
        self.yaw = [NSNumber numberWithFloat:calcGyro(xx, 1)];
    }
}


- (void)turnOn {
    [self writeByte:0x7 forCharacteristicName:@"config" type:CBCharacteristicWriteWithResponse];
    [self setNotifyValue:YES forCharacteristicName:@"data"];
    self.isOn = YES;
}



@end
