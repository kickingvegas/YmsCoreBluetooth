//
//  DEABaseService.h
//  Deanna
//
//  Created by Charles Choi on 4/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"

@interface DEABaseService : YMSCBService

/**
 Request a read of the *config* characteristic.
 */
- (void)requestConfig;

/**
 Return value of the *config* characteristic.
 
 @returns data of *config* characteristic.
 */
- (NSData *)responseConfig;

/**
 Turn on CoreBluetooth peripheral service.
 
 This method turns on the service by:
 
 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.
 
 */
- (void)turnOn;


/**
 Turn off CoreBluetooth peripheral service.
 
 This method turns off the service by:
 
 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.
 
 */
- (void)turnOff;


@end
