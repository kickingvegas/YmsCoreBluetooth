//
//  DTTemperatureBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEABaseService.h"

@interface DTTemperatureBTService : DEABaseService


@property (nonatomic, strong) NSNumber *ambientTemp;
@property (nonatomic, strong) NSNumber *objectTemp;


- (void)updateTemperature;


@end
