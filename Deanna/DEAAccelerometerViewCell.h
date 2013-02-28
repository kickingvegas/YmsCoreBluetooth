//
//  DEAAccelerometerViewCell.h
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DEAAccelerometerService;
@class DEASensorTag;

@interface DEAAccelerometerViewCell : UITableViewCell

@property (strong, nonatomic) DEAAccelerometerService *service;
@property (strong, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (strong, nonatomic) IBOutlet UILabel *accelXLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelYLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelZLabel;

- (IBAction)notifySwitchAction:(id)sender;

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;
- (void)deconfigure;


@end
