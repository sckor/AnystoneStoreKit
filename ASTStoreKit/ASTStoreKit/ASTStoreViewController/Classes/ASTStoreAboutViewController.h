//
//  ASTStoreAboutViewController.h
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-07-08.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTStoreViewController.h"

@interface ASTStoreAboutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
    UIView *gradientView;
    UIImageView *imageView;
    UIImageView *reflectionImageView;
    UITableView *tableView;
    UILabel *versionLabel;
}

@property (nonatomic, assign) id<ASTStoreViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIView *gradientView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *reflectionImageView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

@property (nonatomic,retain) UIColor *cellBackgroundColor1;
@property (nonatomic,retain) UIColor *cellBackgroundColor2;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)anystoneButtonPressed:(id)sender;

@end
