//
//  DTHomeViewController.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YMSCBAppService.h"
#import "DEABaseViewController.h"

@class DEASensorTag;

/**
 View Controller for TI Sensor Tag instance.
 */

@interface DEAHomeViewController : DEABaseViewController <YMSCBAppServiceDelegate>

@property (strong, nonatomic) IBOutlet UILabel *ambientTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *objectTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelXLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelYLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelZLabel;
@property (strong, nonatomic) IBOutlet UISwitch *temperatureSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *accelSwitch;

//@property (strong, nonatomic) UIBarButtonItem *scanButton;
//@property (strong, nonatomic) UIBarButtonItem *connectButton;

@property (strong, nonatomic) DEASensorTag *sensorTag;

- (IBAction)enableAction:(id)sender;

@end
