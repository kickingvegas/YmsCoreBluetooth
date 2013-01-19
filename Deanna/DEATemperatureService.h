//
//  DTTemperatureBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"

@interface DEATemperatureService : YMSCBService


@property (nonatomic, strong) NSNumber *ambientTemp;
@property (nonatomic, strong) NSNumber *objectTemp;

@end
