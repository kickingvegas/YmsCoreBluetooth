//
//  DEAPeripheralsViewController.h
//  Deanna
//
//  Created by Charles Choi on 1/19/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DEACBAppService.h"

/**
 View Controller for listing of TI SensorTags available.
 */

@interface DEAPeripheralsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, YMSCBAppServiceDelegate>

@property (strong, nonatomic) IBOutlet UITableView *peripheralsTableView;

@property (strong, nonatomic) UIBarButtonItem *scanButton;
@property (strong, nonatomic) UIBarButtonItem *connectButton;


@end
