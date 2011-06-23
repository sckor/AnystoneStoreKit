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

@interface ASTStoreDetailViewController ()

@property (readonly) ASTStoreController *storeController;
@property (readonly) ASTStoreProduct *storeProduct;
@end

@implementation ASTStoreDetailViewController

@synthesize purchaseImage = purchaseImage_;
@synthesize productTitle = productTitle_;
@synthesize description = description_;
@synthesize extraInfo = extraInfo_;
@synthesize purchaseButton = purchaseButton_;
@synthesize storeController;
@synthesize storeProduct = storeProduct_;
@synthesize productIdentifier = productIdentifier_;
@synthesize onHand = onHand_;
@synthesize connectingActivityIndicatorView = connectingActivityIndicatorView_;
@synthesize statusLabel = statusLabel_;

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
    // TODO: This should be customizable and associated with the product...
    self.purchaseImage.image = [UIImage imageNamed:@"default-purchase-image.png"];
    
    self.productTitle.text = [self.storeProduct localizedTitle];
    self.description.text = [self.storeProduct localizedDescription];
    self.extraInfo.text = self.storeProduct.extraInformation;
    
    NSString *purchaseTitle = nil;
    NSString *statusText = nil;
    
    if( [self.storeController isProductPurchased:self.productIdentifier] )
    {
        purchaseTitle = @"Purchased - Thank You!";
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
                purchaseTitle = [NSString stringWithFormat:@"Only %@", [self.storeProduct localizedPrice]];
            }
            self.purchaseButton.enabled = YES;
        }
        else
        {
            purchaseTitle = @"Store Error";
            self.purchaseButton.enabled = NO;
        }
    }
    else
    {
        purchaseTitle = @"Connecting to Store";
        self.purchaseButton.enabled = NO;
    }
 
        
    if( self.storeProduct.type == ASTStoreProductIdentifierTypeConsumable )
    {
        self.onHand.text = [NSString stringWithFormat:@"On Hand: %d", 
                            [self.storeController availableQuantityForProduct:self.productIdentifier]];
    }
    else
    {
        self.onHand.text = nil;
    }
    
    if( self.storeController.purchaseState != ASTStoreControllerPurchaseStateNone )
    {
        [self.connectingActivityIndicatorView startAnimating];
        purchaseTitle = @"Please Wait";
    }
    else
    {
        [self.connectingActivityIndicatorView stopAnimating];
    }
    
    switch ( self.storeController.purchaseState ) 
    {
        case ASTStoreControllerPurchaseStateProcessingPayment:
            statusText = @"Processing";
            
            break;
            
        case ASTStoreControllerPurchaseStateVerifyingReceipt:
            statusText = @"Verifying";
            break;
            
        case ASTStoreControllerPurchaseStateDownloadingContent:
            statusText = @"Downloading";
            break;

        default:
            break;
    }
    

    self.statusLabel.text = statusText;
    
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateNormal];
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateHighlighted];

}


#pragma mark Actions

- (IBAction)purchaseButtonPressed:(id)sender 
{
    [self.storeController purchaseProduct:self.productIdentifier];
}

#pragma mark ASTStoreControllerDelegate Methods

- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state
{
    DLog(@"stateChanged:%d", state);
    
    // Update table now that the state of the data has changed
    [self updateViewData];
}

- (void)astStoreControllerPurchaseStateChanged:(ASTStoreControllerPurchaseState)state
{
    DLog(@"purchaseStateChanged:%d", state);
    
    if( ASTStoreControllerPurchaseStateNone == state )
    {
        DLog(@"enable buttons");
        self.purchaseButton.enabled = YES;
        self.purchaseButton.userInteractionEnabled = YES;
    }
    else
    {
        DLog(@"disable buttons");
        self.purchaseButton.enabled = NO;
        self.purchaseButton.userInteractionEnabled = NO;
    }
    
    [self updateViewData];
}

// Should implement this, otherwise no purchase notifications for you
// Restore will invoke astStoreControllerProductIdentifierPurchased: for any restored purchases
- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier
{
    DLog(@"purchased: %@", productIdentifier);
    [self updateViewData];
    self.statusLabel.text = @"Purchase Successful";
}

#pragma mark Purchase Related Delegate Methods
// Invoked for actual purchase failures - may want to display a message to the user
- (void)astStoreControllerProductIdentifierFailedPurchase:(NSString*)productIdentifier withError:(NSError*)error
{
    DLog(@"failed purchase: %@ error:%@", productIdentifier, error);
    self.statusLabel.text = @"Purchase Failed";
}

// Invoked for cancellations - no message should be shown to user per programming guide
- (void)astStoreControllerProductIdentifierCancelledPurchase:(NSString*)productIdentifier
{
    DLog(@"cancelled purchase: %@", productIdentifier);
    self.statusLabel.text = @"Purchase Cancelled";
}


#pragma mark - View lifecycle

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
    {
        // Custom initialization
		isAniPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [self.purchaseButton useBlueConfirmStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewData];
    self.storeController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.storeController.delegate = nil;
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
    
    [connectingActivityIndicatorView_ release];
    connectingActivityIndicatorView_ = nil;
    
    [statusLabel_ release];
    statusLabel_ = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [purchaseImage_ release];
    [productTitle_ release];
    [description_ release];
    [extraInfo_ release];
    [purchaseButton_ release];
    [productIdentifier_ release];    
    [onHand_ release];
    [connectingActivityIndicatorView_ release];
    [statusLabel_ release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}


@end
