//
//  DEAHumidityService.h
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"

/**
 TI SensorTag Humidity Service
 */
@interface DEAHumidityService : YMSCBService


@property (nonatomic, strong) NSNumber *ambientTemp;
@property (nonatomic, strong) NSNumber *relativeHumidity;

@end
