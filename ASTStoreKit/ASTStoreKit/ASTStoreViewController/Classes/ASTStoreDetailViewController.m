//
//  ASTStoreDetailViewController.m
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

#import "ASTStoreDetailViewController.h"
#import "ASTStoreController.h"
#import "UIImageView+ReflectedImage.h"
#import "UIView+SimpleLayerGradient.h"

@interface ASTStoreDetailViewController ()

@property (readonly) ASTStoreController *storeController;
@property (readonly,retain) ASTStoreProduct *storeProduct;
@end

@implementation ASTStoreDetailViewController
@synthesize purchaseFromAppStoreEtchView;
@synthesize appStorePurchaseLabel;
@synthesize inAppPurchaseLabel;

@synthesize gradientView;
@synthesize titleView;
@synthesize purchaseImage = purchaseImage_;
@synthesize productTitle = productTitle_;
@synthesize description = description_;
@synthesize extraInfo = extraInfo_;
@synthesize purchaseButton = purchaseButton_;
@synthesize storeController;
@synthesize storeProduct = storeProduct_;
@synthesize productIdentifier = productIdentifier_;
@synthesize onHand = onHand_;
@synthesize reflectionImageView;
@synthesize purchaseFromAppStoreButton;

- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (ASTStoreProduct*)storeProduct
{
    if( nil != storeProduct_ )
    {
        return storeProduct_;
    }
    
    storeProduct_ = [self.storeController storeProductForIdentifier:self.productIdentifier];
    [storeProduct_ retain];
    
    return ( storeProduct_ );
}


#pragma mark view updates
- (void)updateViewData
{
    self.productTitle.text = [self.storeProduct localizedTitle];
    self.description.text = [self.storeProduct localizedDescription];
    self.extraInfo.text = self.storeProduct.extraInformation;
    
    NSString *purchaseTitle = nil;
    
    if( [self.storeController isProductPurchased:self.productIdentifier] )
    {
        purchaseTitle = NSLocalizedString(@"Purchased - Thank You!", nil);
        self.purchaseButton.enabled = NO;
    }
    else if( self.storeController.productDataState == ASTStoreControllerProductDataStateUpToDate )
    {
        // Check to see if item is valid...
        if( self.storeProduct.isValid )
        {
            if( self.storeProduct.isFree )
            {
                purchaseTitle = [self.storeProduct localizedPrice];    
            }
            else
            {
                purchaseTitle = [NSString stringWithFormat:NSLocalizedString(@"Only %@", @"Only %@"), [self.storeProduct localizedPrice]];
            }
            self.purchaseButton.enabled = YES;
        }
        else
        {
            purchaseTitle = NSLocalizedString(@"Store Error", nil);
            self.purchaseButton.enabled = NO;
        }
    }
    else
    {
        purchaseTitle = NSLocalizedString(@"Connecting to Store", nil);
        self.purchaseButton.enabled = NO;
    }
 
        
    if( self.storeProduct.type == ASTStoreProductIdentifierTypeConsumable )
    {
        self.onHand.text = [NSString stringWithFormat:NSLocalizedString(@"On Hand: %d", @"On Hand: %d"),
                            [self.storeController availableQuantityForProduct:self.productIdentifier]];
    }
    else
    {
        self.onHand.text = nil;
    }
        
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateNormal];
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateHighlighted];
    
    if( self.storeProduct.productDisabledString )
    {
        if( self.purchaseButton.enabled )
        {
            purchaseTitle = [NSString stringWithFormat:NSLocalizedString(@"Only %@ (disabled)", @"Only %@ (disabled)"), [self.storeProduct localizedPrice]];
            self.purchaseButton.enabled = NO;
            self.extraInfo.text = self.storeProduct.productDisabledString;
        }
    }

    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateNormal];
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateHighlighted];
}


#pragma mark Actions

- (IBAction)purchaseButtonPressed:(id)sender 
{
    [self.storeController purchaseProduct:self.productIdentifier];
}

- (IBAction)purchaseFromAppStoreButtonPressed:(id)sender 
{
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:self.storeProduct.appStoreURL];
}

#pragma mark - View lifecycle

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if( UIInterfaceOrientationIsLandscape(interfaceOrientation) )
    {
        [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                         endColor:[UIColor lightGrayColor]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [self.purchaseButton useBlueConfirmStyle];
    [self.purchaseFromAppStoreButton useBlueConfirmStyle];
    
    self.purchaseImage.layer.cornerRadius = 10.0; // Same as the radius that iOS uses
    self.purchaseImage.layer.masksToBounds = YES;
    
    self.reflectionImageView.layer.cornerRadius = 10.0;
    self.reflectionImageView.layer.masksToBounds = YES;
    
    self.title = self.storeProduct.title;
    
    self.appStorePurchaseLabel.text = NSLocalizedString(@"App Store Purchase", @"Area description for app store button");
    self.inAppPurchaseLabel.text = NSLocalizedString(@"In App Purchase", @"Area description for in app purchase button");
    
    NSString *purchaseAppButtonLocalizedTitle = NSLocalizedString(@"Buy from App Store", @"Buy from app store button");
    [self.purchaseFromAppStoreButton setTitle:purchaseAppButtonLocalizedTitle forState:UIControlStateNormal];
    [self.purchaseFromAppStoreButton setTitle:purchaseAppButtonLocalizedTitle forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewData];

    [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                     endColor:[UIColor lightGrayColor]];
    
    self.purchaseImage.image = self.storeProduct.productImage;

    self.reflectionImageView.image = [self.purchaseImage reflectedImageWithHeight:14.0];
    self.reflectionImageView.alpha = 0.4;    
    
    if(( nil == self.storeProduct.appStoreURL ) || 
       ( self.storeProduct.isPurchased ))
    {
        self.purchaseFromAppStoreButton.enabled = NO;
        self.purchaseFromAppStoreButton.alpha = 0.0;
        self.purchaseFromAppStoreEtchView.alpha = 0.0;
        self.appStorePurchaseLabel.alpha = 0.0;
        
        CGRect aFrame = self.description.frame;
        CGRect buttonFrame = self.purchaseFromAppStoreButton.frame;
        
        aFrame.size.height = buttonFrame.origin.y + buttonFrame.size.height;
        self.description.frame = aFrame;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [purchaseImage_ release];
    purchaseImage_ = nil;
    
    [productTitle_ release];
    productTitle_ = nil;
    
    [description_ release];
    description_ = nil;
    
    [extraInfo_ release];
    extraInfo_ = nil;
    
    [purchaseButton_ release];
    purchaseButton_ = nil;
    
    [onHand_ release];
    onHand_ = nil;
    
    [self setReflectionImageView:nil];
    [self setTitleView:nil];
    [self setGradientView:nil];
    [self setPurchaseFromAppStoreButton:nil];
    [self setPurchaseFromAppStoreEtchView:nil];
    [self setAppStorePurchaseLabel:nil];
    [self setInAppPurchaseLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    
    [storeProduct_ release], storeProduct_ = nil;
    [purchaseImage_ release];
    [productTitle_ release];
    [description_ release];
    [extraInfo_ release];
    [purchaseButton_ release];
    [productIdentifier_ release];    
    [onHand_ release];
    
    [reflectionImageView release];
    [titleView release];
    [gradientView release];
    [purchaseFromAppStoreButton release];
    [purchaseFromAppStoreEtchView release];
    [appStorePurchaseLabel release];
    [inAppPurchaseLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

@end
