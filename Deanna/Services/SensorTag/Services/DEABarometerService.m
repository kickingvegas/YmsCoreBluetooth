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


#import "DEABarometerService.h"
#import "YMSCBCharacteristic.h"

@interface DEABarometerService ()

@property (nonatomic, strong) NSNumber *pressure;
@property (nonatomic, strong) NSNumber *ambientTemp;

/// Calibration point
@property (nonatomic, assign) uint16_t c1;
/// Calibration point
@property (nonatomic, assign) uint16_t c2;
/// Calibration point
@property (nonatomic, assign) uint16_t c3;
/// Calibration point
@property (nonatomic, assign) uint16_t c4;
/// Calibration point
@property (nonatomic, assign) int16_t c5;
/// Calibration point
@property (nonatomic, assign) int16_t c6;
/// Calibration point
@property (nonatomic, assign) int16_t c7;
/// Calibration point
@property (nonatomic, assign) int16_t c8;


@end


@implementation DEABarometerService

double calcBarTmp(int16_t t_r, uint16_t c1, uint16_t c2) {
    int32_t t_a;
    
    
    t_a = (((((int32_t)c1 * t_r)/0x100) +
            ((int32_t)c2 * 0x40))*100
           ) / 0x10000;
     

    return (double)t_a/100.0;
}


double calcBarPress(int16_t t_r,
                    uint16_t p_r,
                    uint16_t c3,
                    uint16_t c4,
                    int16_t c5,
                    int16_t c6,
                    int16_t c7,
                    int16_t c8) {
    
    int32_t p_a, S, O;
    
    //calculate pressure
    S=c3+(((int32_t)c4*t_r)/0x20000)+(((((int32_t)c5*t_r)/0x8000)*t_r)/0x80000);
    O=c6*0x4000+(((int32_t)c7*t_r)/8)+(((((int32_t)c8*t_r)/0x8000)*t_r)/16);
    p_a=(S*p_r+O)/0x4000;
    
    // Unit: Pascal (Pa)
    return (double)p_a;
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
        [self addCharacteristic:@"data" withOffset:kSensorTag_BAROMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_BAROMETER_CONFIG];
        [self addCharacteristic:@"calibration" withOffset:kSensorTag_BAROMETER_CALIBRATION];
        _isCalibrating = NO;
    }
    return self;
}

- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    
    if (error) {
        return;
    }

    if ([yc.name isEqualToString:@"data"]) {

        if (self.isCalibrated == NO) {
            return;
        }

        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        int16_t v0 = val[0];
        int16_t v1 = val[1];
        int16_t v2 = val[2];
        int16_t v3 = val[3];
        
        int16_t p_r = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
        int16_t t_r = ((v0 & 0xff)| ((v1 << 8) & 0xff00));

        __weak DEABarometerService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            [self willChangeValueForKey:@"sensorValues"];
            this.pressure = @(calcBarPress(t_r, p_r, _c3, _c4, _c5, _c6, _c7, _c8));
            this.ambientTemp = @(calcBarTmp(t_r, _c1, _c2));
            [self didChangeValueForKey:@"sensorValues"];
        });
    }
}

- (void)requestCalibration {
    if (self.isCalibrating == NO) {
        
        __weak DEABarometerService *this = self;
        
        YMSCBCharacteristic *configCt = self.characteristicDict[@"config"];
        [configCt writeByte:0x2 withBlock:^(NSError *error) {
            if (error) {
                NSLog(@"ERROR: write request to barometer config to start calibration failed.");
                return;
            }
            
            YMSCBCharacteristic *calibrationCt = this.characteristicDict[@"calibration"];
            [calibrationCt readValueWithBlock:^(NSData *data, NSError *error) {
                if (error) {
                    NSLog(@"ERROR: read request to barometer calibration failed.");
                    return;
                }
                
                this.isCalibrating = NO;
                char val[data.length];
                [data getBytes:&val length:data.length];
                
                int i = 0;
                while (i < data.length) {
                    uint16_t lo = val[i];
                    uint16_t hi = val[i+1];
                    uint16_t cx = ((lo & 0xff)| ((hi << 8) & 0xff00));
                    int index = i/2 + 1;
                    
                    if (index == 1) self.c1 = cx;
                    else if (index == 2) this.c2 = cx;
                    else if (index == 3) this.c3 = cx;
                    else if (index == 4) this.c4 = cx;
                    else if (index == 5) this.c5 = cx;
                    else if (index == 6) this.c6 = cx;
                    else if (index == 7) this.c7 = cx;
                    else if (index == 8) this.c8 = cx;
                    
                    i = i + 2;
                }
                
                this.isCalibrating = YES;
                this.isCalibrated = YES;
                
            }];
        }];
        
    }
}

- (NSDictionary *)sensorValues
{
    return @{ @"pressure": self.pressure,
              @"ambientTemp": self.ambientTemp };
}

@end
