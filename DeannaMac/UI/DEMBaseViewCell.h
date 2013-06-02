//
//  DEMBaseViewCell.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DEASensorTag;
@class DEABaseService;

@interface DEMBaseViewCell : NSView

@property (strong, nonatomic) DEABaseService *service;

@property (strong) IBOutlet NSButton *notifySwitch;

/**
 Configure this class to use sensorTag.
 
 @param sensorTag Peripheral containing service to be used by this UI component.
 */
- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

/**
 Deconfigure this class to not use sensorTag.
 */
- (void)deconfigure;

/**
 Action method to handle notifySwitch toggle.
 
 @param sender notifySwitch UI component.
 */
- (IBAction)notifySwitchAction:(id)sender;


@end
