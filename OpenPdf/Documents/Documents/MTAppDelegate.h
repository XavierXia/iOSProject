//
//  MTAppDelegate.h
//  Documents
//
//  Created by Bart Jacobs on 23/02/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTViewController;

@interface MTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MTViewController *viewController;

@end
