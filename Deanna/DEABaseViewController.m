// 
// Copyright 2013 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//

#import "DEABaseViewController.h"
#import "DEACBAppService.h"

@interface DEABaseViewController ()

- (void)cbManagerHandler:(NSNotification *)notification;

@end

@implementation DEABaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSArray *keys = @[YMSCBUnknownNotification,
                      YMSCBResettingNotification,
                      YMSCBUnsupportedNotification,
                      YMSCBUnauthorizedNotification,
                      YMSCBPoweredOffNotification,
                      YMSCBPoweredOnNotification];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    for (NSString *key in keys) {
        [defaultCenter addObserver:self
                          selector:@selector(cbManagerHandler:)
                              name:key
                            object:nil];
        
        
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cbManagerHandler:(NSNotification *)notification {
    NSLog(@"notification: %@", notification.name);
    
    if ([notification.name isEqualToString:YMSCBUnknownNotification]) {
        
    } else if ([notification.name isEqualToString:YMSCBResettingNotification]) {
 
    } else if ([notification.name isEqualToString:YMSCBUnsupportedNotification]) {
     
    } else if ([notification.name isEqualToString:YMSCBUnauthorizedNotification]) {

    } else if ([notification.name isEqualToString:YMSCBPoweredOnNotification]) {
        
    } else if ([notification.name isEqualToString:YMSCBPoweredOffNotification]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BTLE is off"
                                                        message:@"yo turn it on!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
}

@end
