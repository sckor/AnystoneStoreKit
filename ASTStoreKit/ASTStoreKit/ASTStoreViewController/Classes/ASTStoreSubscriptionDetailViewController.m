//
//  ASTStoreSubscriptionDetailViewController.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-28.
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

#import "ASTStoreSubscriptionDetailViewController.h"
#import "ASTStoreController.h"
#import "UIImageView+ReflectedImage.h"
#import "UIView+SimpleLayerGradient.h"
#import "ASTStoreViewControllerCommon.h"

@interface ASTStoreSubscriptionDetailViewController ()

@property (readonly) ASTStoreController *storeController;
@property (readonly,retain) ASTStoreProduct *storeProduct;
@property (readonly,retain) NSArray *familyProducts;

@end

@implementation ASTStoreSubscriptionDetailViewController
@dynamic storeController;
@synthesize storeProduct = storeProduct_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize gradientView;
@synthesize purchaseImage;
@synthesize reflectionImageView;
@synthesize productTitle;
@synthesize expiresLabel;
@synthesize description;
@synthesize extraInfo;
@synthesize tableView;
@synthesize familyProducts = familyProducts_;
@synthesize cellBackgroundColor1 = cellBackgroundColor1_;
@synthesize cellBackgroundColor2 = cellBackgroundColor2_;
@synthesize storeCell = storeCell_;



#pragma mark - Accessors

- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (NSArray*)familyProducts
{
    if( nil == familyProducts_ )
    {        
        familyProducts_ = [self.storeController storeProductsForFamilyIdentifier:self.familyIdentifier];
        [familyProducts_ retain];
    }
    
    ASTReturnRA( familyProducts_ );    
}

- (ASTStoreProduct*)storeProduct
{
    if( nil != storeProduct_ )
    {
        return storeProduct_;
    }
    
    // Pick a representative sample since the content will be the same for the title, description and expiry
    storeProduct_ = [self.familyProducts objectAtIndex:0];
    [storeProduct_ retain];
    
    return ( storeProduct_ );
}

- (UIColor*)cellBackgroundColor1
{
    if( nil == cellBackgroundColor1_ )
    {
        self.cellBackgroundColor1 = [UIColor lightGrayColor];
    }
    
    ASTReturnRA(cellBackgroundColor1_);
}

- (UIColor*)cellBackgroundColor2
{
    if( nil == cellBackgroundColor2_ )
    {
        self.cellBackgroundColor2 = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    
    ASTReturnRA(cellBackgroundColor2_);    
}


#pragma mark view updates
- (void)updateViewData
{
    self.productTitle.text = [self.storeProduct localizedTitle];
    self.description.text = [self.storeProduct localizedDescription];
    
    NSString *expiryDateAsString = [NSDateFormatter localizedStringFromDate:self.storeProduct.expiresDate 
                                                                  dateStyle:kCFDateFormatterMediumStyle 
                                                                  timeStyle:kCFDateFormatterShortStyle];
    NSString *expiresString = nil;
    
    
    if( nil == expiryDateAsString )
    {
        self.expiresLabel.text = nil;
        return;
    }
    
    if( self.storeProduct.isPurchased )
    {
        self.expiresLabel.textColor = [UIColor blackColor];
        expiresString = NSLocalizedString(@"Expires: ", nil);
    }
    else
    {
        self.expiresLabel.textColor = [UIColor redColor];
        expiresString = NSLocalizedString(@"Expired: ", nil);
    }
                              
    self.expiresLabel.text = [NSString stringWithFormat:@"%@%@", expiresString, expiryDateAsString];
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
    }
    else
    {
    }
    
    [self updateViewData];
}

// Should implement this, otherwise no purchase notifications for you
// Restore will invoke astStoreControllerProductIdentifierPurchased: for any restored purchases
- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier
{
    DLog(@"purchased: %@", productIdentifier);
    [self updateViewData];
}

#pragma mark Purchase Related Delegate Methods
// Invoked for actual purchase failures - may want to display a message to the user
- (void)astStoreControllerProductIdentifierFailedPurchase:(NSString*)productIdentifier withError:(NSError*)error
{
    DLog(@"failed purchase: %@ error:%@", productIdentifier, error);
}

// Invoked for cancellations - no message should be shown to user per programming guide
- (void)astStoreControllerProductIdentifierCancelledPurchase:(NSString*)productIdentifier
{
    DLog(@"cancelled purchase: %@", productIdentifier);
}

#pragma mark - Button Actions

- (void)purchaseButtonPressed:(id)sender
{
    GradientButton *button = sender;
    ASTStoreProduct *productForButton = nil;
    
    // Determine which cell sent the button press
    for( UITableViewCell *aCell in [self.tableView visibleCells] )
    {
        if( [button isDescendantOfView:aCell] )
        {
            NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:aCell];
            productForButton = [self.familyProducts objectAtIndex:indexPathForCell.row];
            break;
        }
    }
    
    // Get product - invoke appropriate method
    [self.storeController purchaseProduct:productForButton.productIdentifier];
}

#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.familyProducts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    updateCellBackgrounds(cell, indexPath, self.cellBackgroundColor1, self.cellBackgroundColor2);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{    
    
    UILabel *titleLabel = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagTitleLabel];
    UILabel *extraInfoLabel = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagExtraInfoLabel];
    GradientButton *purchaseButton = (GradientButton*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagPurchaseButton];

    NSString *title = nil;
    ASTStoreProduct *aProduct = [self.familyProducts objectAtIndex:indexPath.row];
    
    switch (aProduct.familyQuanity) 
    {
        case ASTStoreProductAutoRenewableType7Days:
            title = NSLocalizedString(@"7 Days", nil);
            break;
            
        case ASTStoreProductAutoRenewableType1Month:
            title = NSLocalizedString(@"1 Month", nil);
            break;

        case ASTStoreProductAutoRenewableType2Months:
            title = NSLocalizedString(@"2 Months", nil);
            break;

        case ASTStoreProductAutoRenewableType3Months:
            title = NSLocalizedString(@"3 Months", nil);
            break;

        case ASTStoreProductAutoRenewableType6Months:
            title = NSLocalizedString(@"6 Months", nil);
            break;

        case ASTStoreProductAutoRenewableType1Year:
            title = NSLocalizedString(@"1 Year", nil);
            break;

        default:
            break;
    }
    
    titleLabel.text = title;
    extraInfoLabel.text = aProduct.extraInformation;
    
    DLog(@"%@ price", aProduct.localizedPrice);
    
    [purchaseButton setTitle:aProduct.localizedPrice forState:UIControlStateNormal];
    [purchaseButton setTitle:aProduct.localizedPrice forState:UIControlStateSelected];
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ASTStoreSubscriptionTableViewCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"ASTStoreSubscriptionTableViewCell" owner:self options:nil];
        cell = storeCell_;
        self.storeCell = nil;
                
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.backgroundView.autoresizesSubviews = YES;
        cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        GradientButton *purchaseButton = (GradientButton*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagPurchaseButton];
        [purchaseButton useBlueConfirmStyle];
        
        [purchaseButton addTarget:self
                           action:@selector(purchaseButtonPressed:) 
                 forControlEvents:UIControlEventTouchUpInside];
     }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ( 43.0 );
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [storeProduct_ release], storeProduct_ = nil;
    [familyIdentifier_ release], familyIdentifier_ = nil;
    [familyProducts_ release], familyProducts_ = nil;
    
    [cellBackgroundColor1_ release], cellBackgroundColor1_ = nil;
    [cellBackgroundColor2_ release], cellBackgroundColor2_ = nil;
    
    [storeCell_ release], storeCell_ = nil;
    
    [gradientView release];
    [purchaseImage release];
    [reflectionImageView release];
    [productTitle release];
    [expiresLabel release];
    [description release];
    [extraInfo release];
    [tableView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseImage.layer.cornerRadius = 10.0; // Same as the radius that iOS uses
    self.purchaseImage.layer.masksToBounds = YES;
    
    self.reflectionImageView.layer.cornerRadius = 10.0;
    self.reflectionImageView.layer.masksToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewData];

    [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                     endColor:[UIColor lightGrayColor]];
    
    self.reflectionImageView.image = [self.purchaseImage reflectedImageWithHeight:14.0];
    self.reflectionImageView.alpha = 0.4;
    
    self.storeController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.storeController.delegate = nil;
}

- (void)viewDidUnload
{
    [self setGradientView:nil];
    [self setPurchaseImage:nil];
    [self setReflectionImageView:nil];
    [self setProductTitle:nil];
    [self setExpiresLabel:nil];
    [self setDescription:nil];
    [self setExtraInfo:nil];
    [self setTableView:nil];
    self.storeCell = nil;

    [super viewDidUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if( UIInterfaceOrientationIsLandscape(interfaceOrientation) )
    {
        [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                         endColor:[UIColor lightGrayColor]];
        
        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
