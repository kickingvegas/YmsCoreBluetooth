//
//  DTSimpleKeysBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/20/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"

/**
 TI SensorTag CoreBluetooth service definition for simple keys service.
 */
@interface DEASimpleKeysService : YMSCBService

@property (nonatomic, strong) NSNumber *keyValue;

@end
