//
//  DEACBAppService.h
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "YMSCBAppService.h"

/**
 Deanna TI SensorTag CoreBluetooth Application Service.
 
 This class defines a singleton application service instance which manages access to
 the TI SensorTag via the CoreBluetooth API. 
 
 THIS IS NOT A COREBLUETOOTH SERVICE.
 */
@interface DEACBAppService : YMSCBAppService

/**
 Return singleton instance.
 */
+ (DEACBAppService *)sharedService;

@end
