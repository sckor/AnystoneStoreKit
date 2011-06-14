//
//  ASTStoreKitAppDelegate.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-13.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import "ASTStoreKitAppDelegate.h"

#import "ASTStoreController.h"

@implementation ASTStoreKitAppDelegate


@synthesize tabBarController = _tabBarController;
@synthesize window=_window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize the store controller right away so that it can get any outstanding transactions
    ASTStoreController *sc = [ASTStoreController sharedStoreController];
    
    // Setup the list of products to manage (in this case using a local plist file)
    // Do not request the product information here though - want to wait until the customer
    // Goes into the store, since there may not be any need contact iTunes
    NSArray *productIdentifiers = [sc productIdentifiers];
    if( nil == productIdentifiers )
    {
        DLog(@"Did not read sampleProductIdentifiers based on ASTStoreKitConfig file - oh no!");
    }
    else
    {
        DLog(@"Configured for the following ids:%@", productIdentifiers);
    }
     
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

@end
