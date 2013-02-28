//
//  DEASensorTagViewController.h
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEABaseViewController.h"
#import "YMSCBAppService.h"
@class DEASensorTag;
@class DEATemperatureViewCell;

@interface DEASensorTagViewController : DEABaseViewController <UITableViewDelegate, UITableViewDataSource, YMSCBAppServiceDelegate>

@property (strong, nonatomic) NSArray *cbServiceCells;
@property (strong, nonatomic) DEASensorTag *sensorTag;

@property (strong, nonatomic) IBOutlet UITableView *sensorTableView;
@property (strong, nonatomic) IBOutlet DEATemperatureViewCell *temperatureViewCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *accelerometerViewCell;

@end
