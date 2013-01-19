//
//  DTCharacteristic.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBCharacteristic.h"

@implementation YMSCBCharacteristic


- (id)initWithName:(NSString *)oName uuid:(CBUUID *)oUUID offset:(int)addrOffset {
    self = [super init];
    
    if (self) {
        _name = oName;
        _uuid = oUUID;
        _offset = [NSNumber numberWithInt:addrOffset];
    }
    
    return self;
}




@end
