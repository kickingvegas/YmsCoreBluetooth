//
//  DTAppDelegate.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 AppDelegate
 */
@interface DEAAppDelegate : UIResponder <UIApplicationDelegate>

/// window
@property (strong, nonatomic) UIWindow *window;

/**
 Initialize user defaults.
 */
- (void)initializeUserDefaults;

/**
 Initialize app services.
 */
- (void)initializeAppServices;


@end
