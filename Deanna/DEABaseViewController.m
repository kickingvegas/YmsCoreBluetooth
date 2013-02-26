//
//  DEABaseViewController.m
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
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
