//
//  DEAPeripheralsViewController.h
//  Deanna
//
//  Created by Charles Choi on 1/19/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DEAPeripheralsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *peripheralsTableView;

@end
