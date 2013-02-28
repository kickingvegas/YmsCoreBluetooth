//
//  DEATemperatureViewCell.h
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DEATemperatureService;
@class DEASensorTag;

@interface DEATemperatureViewCell : UITableViewCell

@property (strong, nonatomic) DEATemperatureService *service;

@property (strong, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (strong, nonatomic) IBOutlet UILabel *ambientTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *objectTemperatureLabel;

- (IBAction)notifySwitchAction:(id)sender;

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;
- (void)deconfigure;

@end
