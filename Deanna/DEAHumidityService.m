//
//  DEAHumidityService.m
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEAHumidityService.h"
#import "YMSCBCharacteristic.h"

double calcHumTmp(int16_t rawT) {
    double v;
    v = -46.85 + 175.72/65536 *(double)rawT;
    return v;
}

double calcHumRel(int16_t rawH) {
    double v;
    v = -6.0 + (125.0/65536.0) * (double)rawH;
    return v;
}


@implementation DEAHumidityService

- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_HUMIDITY_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_HUMIDITY_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_HUMIDITY_CONFIG];
    }
    return self;
    
}


- (void)update {
    YMSCBCharacteristic *yc = self.characteristicDict[@"data"];
    NSData *data = yc.cbCharacteristic.value;
    
    char val[data.length];

    [data getBytes:&val length:data.length];
    
    int16_t v0 = val[0];
    int16_t v1 = val[1];
    int16_t v2 = val[2];
    int16_t v3 = val[3];

    
    int16_t rawHumidity = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
    int16_t rawTemperature = ((v0 & 0xff)| ((v1 << 8) & 0xff00));
    
    self.ambientTemp = [NSNumber numberWithDouble:calcHumTmp(rawTemperature)];
    self.relativeHumidity = [NSNumber numberWithDouble:calcHumRel(rawHumidity)];
    
    NSLog(@"at: %@  hum: %@", self.ambientTemp, self.relativeHumidity);

}

@end
