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

#import "DEAMagnetometerService.h"
#import "YMSCBCharacteristic.h"

@implementation DEAMagnetometerService

float calcMag(int16_t v, float c, int16_t d) {
    float result;
    
    result = (((float)v * d) / (65536/2000.0)) - c;
    
    return result;
}

- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    if (self) {
        [self addCharacteristic:@"data" withOffset:kSensorTag_MAGNETOMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_MAGNETOMETER_CONFIG];
        [self addCharacteristic:@"period" withOffset:kSensorTag_MAGNETOMETER_PERIOD];
        _lastX = 0.0;
        _lastY = 0.0;
        _lastZ = 0.0;
        _cX= 0.0;
        _cY = 0.0;
        _cZ = 0.0;
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
        
        self.lastX = calcMag(xx, self.cX, 1);
        self.lastY = calcMag(yy, self.cY, 1);
        self.lastZ = calcMag(zz, self.cZ, 1);
        
        __weak DEAMagnetometerService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.x = [NSNumber numberWithFloat:this.lastX];
            this.y = [NSNumber numberWithFloat:this.lastY];
            this.z = [NSNumber numberWithFloat:this.lastZ];
        });

    } else if ([yc.name isEqualToString:@"config"]) {
        
    }
}


- (void)calibrate {
    self.cX = self.lastX;
    self.cY = self.lastY;
    self.cZ = self.lastZ;
}


@end
