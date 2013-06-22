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

#import "DEAAccelerometerService.h"
#import "YMSCBCharacteristic.h"


float calcAccel(int16_t rawV) {
    float v;
    v = ((float)rawV + 1.0) / (256.0/4.0);
    return v;
}

@implementation DEAAccelerometerService


- (id)initWithName:(NSString *)oName
            parent:(YMSCBPeripheral *)pObj
            baseHi:(int64_t)hi
            baseLo:(int64_t)lo {
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo];
    
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_ACCELEROMETER_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_ACCELEROMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_ACCELEROMETER_CONFIG];
        [self addCharacteristic:@"period" withOffset:kSensorTag_ACCELEROMETER_PERIOD];
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
        
        int16_t xx = val[0];
        int16_t yy = val[1];
        int16_t zz = val[2];
        
        __weak DEAAccelerometerService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.x = [NSNumber numberWithFloat:calcAccel(xx)];
            this.y = [NSNumber numberWithFloat:calcAccel(yy)];
            this.z = [NSNumber numberWithFloat:calcAccel(zz)];
        });
    }
}




@end
