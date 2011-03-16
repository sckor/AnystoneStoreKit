//
//  ASTStoreDetailViewController.h
//  ASTStore
//
//  Created by Sean Kormilo on 11-03-16.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTStoreController.h"

@interface ASTStoreDetailViewController : UIViewController <ASTStoreControllerDelegate>
{
    UIImageView *purchaseImage_;
    UILabel *productTitle_;
    UITextView *description_;
    UILabel *extraInfo_;
    UIButton *purchaseButton_;
    
    NSString *productIdentifier_;
    UILabel *onHand_;
}

- (IBAction)purchaseButtonPressed:(id)sender;

@property (retain) IBOutlet UIImageView *purchaseImage;
@property (retain) IBOutlet UILabel *productTitle;
@property (retain) IBOutlet UITextView *description;
@property (retain) IBOutlet UILabel *extraInfo;
@property (retain) IBOutlet UIButton *purchaseButton;
@property (retain) IBOutlet UILabel *onHand;

@property (retain) NSString *productIdentifier;

@end
