//
//  ASTStoreKitAppDelegate.h
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-13.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTStoreKitViewController;

@interface ASTStoreKitAppDelegate : NSObject <UIApplicationDelegate> {

    UITabBarController *_tabBarController;
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
