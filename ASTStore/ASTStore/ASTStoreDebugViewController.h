//
//  ASTStoreDebugViewController.h
//  ASTStore
//
//  Created by Sean Kormilo on 11-05-06.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ASTStoreDebugViewController : UIViewController <UITextFieldDelegate>
{
    UITextField *urlTextField;
    UIButton *removeAllPurchaseDataButton;
    UISwitch *serverEnabledSwitch;
}

@property (nonatomic, retain) IBOutlet UISwitch *serverEnabledSwitch;
@property (nonatomic, retain) IBOutlet UITextField *urlTextField;
@property (nonatomic, retain) IBOutlet UIButton *removeAllPurchaseDataButton;
- (IBAction)removeAllPurchaseDataButtonPressed:(id)sender;
- (IBAction)serverEnabledSwitchValueChanged:(id)sender;

@end
