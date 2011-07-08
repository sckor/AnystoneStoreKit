//
//  ASTStoreDetailViewController.h
//  ASTStore
//
//  Created by Sean Kormilo on 11-03-16.
//  http://www.anystonetech.com

//  Copyright (c) 2011 Anystone Technologies, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "AlertSliderWindow.h"
#import "ASTStoreController.h"
#import "GradientButton.h"

@interface ASTStoreDetailViewController : UIViewController
<
GKPeerPickerControllerDelegate, 
GKSessionDelegate,
ASTStoreControllerDelegate,
UIAlertViewDelegate
>
{
    UIImageView *purchaseImage_;
    UILabel *productTitle_;
    UITextView *description_;
    UILabel *extraInfo_;
    GradientButton *purchaseButton_;
    
    NSString *productIdentifier_;
    UILabel *onHand_;
    
    UIImageView *reflectionImageView;
    UIView *titleView;
    UIView *gradientView;
    
    GKSession *_session;
    NSString *_peerID;
    AlertSliderWindow *sliderAlert;

}

- (IBAction)purchaseButtonPressed:(id)sender;

@property (nonatomic, retain) AlertSliderWindow *sliderAlert;

- (void)updateViewData;

- (IBAction)purchaseButtonPressed:(id)sender;
@property (nonatomic, retain) IBOutlet UIView *gradientView;

@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (retain) IBOutlet UIImageView *purchaseImage;
@property (retain) IBOutlet UILabel *productTitle;
@property (retain) IBOutlet UITextView *description;
@property (retain) IBOutlet UILabel *extraInfo;
@property (retain) IBOutlet GradientButton *purchaseButton;
@property (retain) IBOutlet UILabel *onHand;

@property (retain) NSString *productIdentifier;
@property (nonatomic, retain) IBOutlet UIImageView *reflectionImageView;

@end
