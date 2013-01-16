//
//  DTSimpleKeysBTService.m
//  Deanna
//
//  Created by Charles Choi on 12/20/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEASimpleKeysService.h"
#import "DEACharacteristic.h"

@implementation DEASimpleKeysService


- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withAddress:kSensorTag_SIMPLEKEYS_SERVICE];
        [self addCharacteristic:@"data" withAddress:kSensorTag_SIMPLEKEYS_DATA];
    }
    return self;
}

- (NSArray *)characteristics {
    
    NSArray *result = @[
    [(DEACharacteristic *)(self.characteristicMap[@"data"]) uuid]
    ];
    
    return result;
}






- (void)updateKeyPress {
    DEACharacteristic *dtc = self.characteristicMap[@"data"];
    NSData *data = dtc.characteristic.value;
    
    char val[data.length];
    [data getBytes:&val length:data.length];
    
    
    int16_t value = val[0];
    
    
    self.keyValue = [NSNumber numberWithInt:value];
    
    NSLog(@"key value: %@", self.keyValue);
    


}

@end
