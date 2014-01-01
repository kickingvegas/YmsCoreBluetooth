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

#import "DEATemperatureService.h"
#import "YMSCBCharacteristic.h"

double calcTmpLocal(int16_t rawT) {
    double m_tempAmb = (double)rawT / 128.0;
    return m_tempAmb;
}

double calcTmpTarget(int16_t objT, double m_tempAmb) {
    double Vobj2 = (double)objT;
    Vobj2 *= 0.00000015625;
    
    double Tdie2 = m_tempAmb + 273.15;
    const double S0 = 6.4E-14;            // Calibration factor
    
    const double a1 = 1.75E-3;
    const double a2 = -1.678E-5;
    const double b0 = -2.94E-5;
    const double b1 = -5.7E-7;
    const double b2 = 4.63E-9;
    const double c2 = 13.4;
    const double Tref = 298.15;
    double S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2));
    double Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2);
    double fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2);
    double tObj = pow(pow(Tdie2,4) + (fObj/S),.25);
    tObj = (tObj - 273.15);
    
    return tObj;
    
}

@interface DEATemperatureService ()

@property (nonatomic, strong) NSNumber *ambientTemp;
@property (nonatomic, strong) NSNumber *objectTemp;

@end


@implementation DEATemperatureService

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
        [self addCharacteristic:@"data" withOffset:kSensorTag_TEMPERATURE_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_TEMPERATURE_CONFIG];
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
        
        int16_t v0 = val[0];
        int16_t v1 = val[1];
        int16_t v2 = val[2];
        int16_t v3 = val[3];
        
        int16_t amb = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
        int16_t objT = ((v0 & 0xff)| ((v1 << 8) & 0xff00));
        
        double tempAmb = calcTmpLocal(amb);

        __weak DEATemperatureService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            [self willChangeValueForKey:@"sensorValues"];
            this.ambientTemp = @(tempAmb);
            this.objectTemp = @(calcTmpTarget(objT, tempAmb));
            [self didChangeValueForKey:@"sensorValues"];
        });
    }
}

- (NSDictionary *)sensorValues
{
    return @{ @"ambientTemp": self.ambientTemp,
              @"objectTemp": self.objectTemp };
}

@end
