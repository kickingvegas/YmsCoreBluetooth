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


#import "DEABarometerService.h"
#import "YMSCBCharacteristic.h"

@implementation DEABarometerService

double calcBarTmp(int16_t rawT, uint16_t c1, uint16_t c2) {
    int64_t temp, val;
    val = (int64_t)(c1 * rawT) * 100;
    temp = val >> 24;
    val = c2 * 100;
    temp += (val >> 10);
    
    return (double)temp / 100.0;
}


double calcBarPress(int16_t Pr,
                    int16_t Tr,
                    uint16_t c3,
                    uint16_t c4,
                    int16_t c5,
                    int16_t c6,
                    int16_t c7,
                    int16_t c8) {
    
    int64_t s, o, pres, val;
    
    s = (int64_t)c3;
    val = (int64_t)c4 + Tr;
    s += (val >> 17);
    val = (int64_t)c5 * Tr * Tr;
    s += (val >> 34);
    
    o = (int64_t)c6 << 14;
    val = (int64_t)c7 * Tr;
    o += (val >> 3);
    val = (int64_t)c8 * Tr * Tr;
    o += (val >> 19);
    
    pres = ((int64_t)(s * Pr) + o) >> 14;
    
    return (double)pres / 100;

}
                    

- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_BAROMETER_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_BAROMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_BAROMETER_CONFIG];
        [self addCharacteristic:@"calibration" withOffset:kSensorTag_BAROMETER_CALIBRATION];
        _isCalibrating = NO;
    }
    return self;
}

- (void)updateCharacteristic:(YMSCBCharacteristic *)yc {
    NSLog(@"barometer characteristic: %@", yc.name);
    if ([yc.name isEqualToString:@"data"]) {
        
        // First get calibration data
        
        if (self.calibrationData == nil) {
            return;
        }
        
        char rawVal[self.calibrationData.length];
        uint16_t c[self.calibrationData.length/2];
        
        [self.calibrationData getBytes:&rawVal length:self.calibrationData.length];
        
        int i = 0;
        while (i < self.calibrationData.length) {
            uint16_t lo = rawVal[i];
            uint16_t hi = rawVal[i+1];
            int index = i/2;
            c[index] = ((lo & 0xff)| ((hi << 8) & 0xff00));
            
            //NSLog(@"%d %d", index, c[index]);
            i = i + 2;
        }

        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        
        int16_t v0 = val[0];
        int16_t v1 = val[1];
        int16_t v2 = val[2];
        int16_t v3 = val[3];
        
        
        int16_t rawP = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
        
        int16_t ambT = ((v0 & 0xff)| ((v1 << 8) & 0xff00));
        
        
        self.ambientTemp = [NSNumber numberWithDouble:calcBarTmp(ambT, c[0], c[1])];
        self.pressure = [NSNumber numberWithDouble:calcBarPress(rawP,
                                                                ambT,
                                                                c[2],
                                                                c[3],
                                                                c[4],
                                                                c[5],
                                                                c[6],
                                                                c[7])];
        
        
        

    } else if ([yc.name isEqualToString:@"config"]) {
        if (self.isCalibrating) {
            [self readValueForCharacteristicName:@"calibration"];
        }
        
    } else if ([yc.name isEqualToString:@"calibration"]) {
        NSLog(@"barometer calibration");
        self.isCalibrating = NO;
        NSData *data = yc.cbCharacteristic.value;
        
        self.calibrationData = [[NSData alloc] initWithData:data];
        
        char val[self.calibrationData.length];
        [data getBytes:&val length:self.calibrationData.length];
        
        int i = 0;
        while (i < self.calibrationData.length) {
            uint16_t lo = val[i];
            uint16_t hi = val[i+1];
            uint16_t cx = ((lo & 0xff)| ((hi << 8) & 0xff00));
            
            NSLog(@"%d %d", i/2, cx);
            i = i + 2;
        }
    }
}








@end
