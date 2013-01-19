//
//  DTHomeViewController.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DEAHomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *ambientTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *objectTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelXLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelYLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelZLabel;
@property (strong, nonatomic) IBOutlet UISwitch *temperatureSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *accelSwitch;
@property (strong, nonatomic) IBOutlet UILabel *connectedLabel;


- (IBAction)enableAction:(id)sender;

@end
