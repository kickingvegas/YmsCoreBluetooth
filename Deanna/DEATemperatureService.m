//
//  DTTemperatureBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEATemperatureService.h"
#import "DEACharacteristic.h"

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

@implementation DEATemperatureService

- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_TEMPERATURE_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_TEMPERATURE_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_TEMPERATURE_CONFIG];
    }
    return self;
}

- (void)updateTemperature {
    DEACharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    
    int16_t amb = ((val[2] & 0xff)| ((val[3] << 8) & 0xff00));
    
    int16_t objT = ((val[0] & 0xff)| ((val[1] << 8) & 0xff00));
    
    double tempAmb = calcTmpLocal(amb);
    
    self.ambientTemp = [NSNumber numberWithDouble:tempAmb];
    self.objectTemp = [NSNumber numberWithDouble:calcTmpTarget(objT, tempAmb)];

}

@end
