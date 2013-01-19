//
//  DTCharacteristic.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface YMSCBCharacteristic : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CBUUID *uuid;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSNumber *offset;


- (id)initWithName:(NSString *)oName uuid:(CBUUID *)oUUID offset:(int)addrOffset;


@end
