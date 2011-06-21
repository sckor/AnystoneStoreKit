//
//  ASTStoreViewController.m
//  ASTStore
//
//  Created by Sean Kormilo on 11-03-07.
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

#import <QuartzCore/QuartzCore.h>

#import "ASTStoreViewController.h"
#import "ASTStoreDetailViewController.h"
#import "ASTWebViewController.h"

typedef enum
{
    ASTStoreViewControllerTableViewCellTagImageView = 1,
    ASTStoreViewControllerTableViewCellTagTitleLabel = 2,
    ASTStoreViewControllerTableViewCellTagDescriptionLabel = 3,
    ASTStoreViewControllerTableViewCellTagExtraInfoLabel = 4,
    ASTStoreViewControllerTableViewCellTagPriceLabel = 5,
    ASTStoreViewControllerTableViewCellTagTopLineView = 6,
    ASTStoreViewControllerTableViewCellTagBottomLineView = 7,
    ASTStoreViewControllerTableViewCellTagDropShadowView = 8
} ASTStoreViewControllerTableViewCellTags;

@interface ASTStoreViewController()

@property (readonly) ASTStoreController *storeController;
@property (nonatomic,retain) NSArray *productIdentifiers;
@property BOOL restoreDidFail;
@end


@implementation ASTStoreViewController

#pragma mark Synthesis

@synthesize tableContainerView = tableContainerView_;
@synthesize tableView = tableView_;
@synthesize storeCell = storeCell_;
@synthesize restorePreviousPurchaseButton = restorePreviousPurchaseButton_;
@synthesize connectingToStoreLabel = connectingToStoreLabel_;
@synthesize connectingActivityIndicatorView = connectingActivityIndicatorView_;
@synthesize productIdentifiers = productIdentifiers_;
@synthesize delegate;
@synthesize cellBackgroundColor1 = cellBackgroundColor1_;
@synthesize cellBackgroundColor2 = cellBackgroundColor2_;
@synthesize restoreDidFail = restoreDidFail_;


- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (NSArray*)productIdentifiers
{
    if( nil == productIdentifiers_ )
    {
        self.productIdentifiers = [self.storeController sortedProductIdentifiers];
    }
    
    return [[productIdentifiers_ retain] autorelease];
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
#pragma mark User Interface

- (IBAction)restorePreviousPurchaseButtonPressed:(id)sender
{
    [self.storeController restorePreviousPurchases];
}


- (void)setConnectingToStoreLabelText:(NSString*)newText animateActivityIndicator:(BOOL)animateActivityIndicator
{
    float fadeDuration = 0.3;
    
    if( [newText isEqualToString:self.connectingToStoreLabel.text] )
    {
        return;
    }
    
    if( nil == newText )
    {
        [UIView animateWithDuration:fadeDuration 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:
         ^(void) 
         { 
             self.connectingToStoreLabel.alpha = 0.0;
             self.connectingActivityIndicatorView.alpha = 0.0;
         }
                         completion:
         ^(BOOL finished) 
         {
             self.connectingToStoreLabel.text = nil;
             [self.connectingActivityIndicatorView stopAnimating];
         }];
        

        return;
    }
    
    // Fade out and fade in 
    [UIView animateWithDuration:fadeDuration 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:
     ^(void) 
     { 
         self.connectingToStoreLabel.alpha = 0.0;
         self.connectingActivityIndicatorView.alpha = 0.0;
     }
                     completion:
     ^(BOOL finished) 
     {
         float indicatorAlpha = 0.0;
         
         self.connectingToStoreLabel.text = newText;
         if( YES == animateActivityIndicator )
         {
             [self.connectingActivityIndicatorView startAnimating];
             indicatorAlpha = 1.0;
         }
         else
         {
             [self.connectingActivityIndicatorView stopAnimating];
         }
         
         [UIView animateWithDuration:fadeDuration 
                               delay:(fadeDuration * 0.5)
                             options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                          animations:
          ^(void)
          { 
              self.connectingToStoreLabel.alpha = 1.0; 
              self.connectingActivityIndicatorView.alpha = indicatorAlpha;
          }
                          completion:nil];
     }];

}

- (void)updateStoreStateDisplay
{
    if( self.storeController.purchaseState == ASTStoreControllerPurchaseStateNone )
    {
        switch ( self.storeController.productDataState ) 
        {            
            case ASTStoreControllerProductDataStateUpdating:
                [self setConnectingToStoreLabelText:@"Connecting to Store" animateActivityIndicator:YES];
                break;
                
            case ASTStoreControllerProductDataStateUpToDate:
                if( self.restoreDidFail )
                {
                    [self setConnectingToStoreLabelText:@"Restore Failed" animateActivityIndicator:NO];
                    self.restoreDidFail = NO;
                }
                else
                {
                    [self setConnectingToStoreLabelText:@"Store Ready" animateActivityIndicator:NO];
                }
                
                self.productIdentifiers = nil;
                [self.tableView reloadData];
                
                double delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   [self setConnectingToStoreLabelText:nil animateActivityIndicator:NO];
                               });
                
                break;
                
            case ASTStoreControllerProductDataStateUnknown:
            case ASTStoreControllerProductDataStateStale:
            case ASTStoreControllerProductDataStateStaleTimeout:
            default:
                [self setConnectingToStoreLabelText:@"Store Not Available" animateActivityIndicator:NO];
                break;
        }
    }
    else
    {
        switch ( self.storeController.purchaseState ) 
        {
            case ASTStoreControllerPurchaseStateProcessingPayment:
                [self setConnectingToStoreLabelText:@"Processing" animateActivityIndicator:YES];
                break;
                
            case ASTStoreControllerPurchaseStateVerifyingReceipt:
                [self setConnectingToStoreLabelText:@"Verifying" animateActivityIndicator:YES];
                break;
                
            case ASTStoreControllerPurchaseStateDownloadingContent:
                [self setConnectingToStoreLabelText:@"Downloading" animateActivityIndicator:YES];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ( [self.productIdentifiers count] );
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView = cell.backgroundView;
    
    if((indexPath.row % 2) == 0 )
    {
        backgroundView.backgroundColor = self.cellBackgroundColor1;
    }
    else
    {
        backgroundView.backgroundColor = self.cellBackgroundColor2;
    }
    
    
    if(( backgroundView.frame.size.height != 0.0 ) &&
       ( backgroundView.frame.size.width != 0.0 ))
    {
        UIView *topLineView = [backgroundView viewWithTag:ASTStoreViewControllerTableViewCellTagTopLineView];
        UIView *bottomLineView = [backgroundView viewWithTag:ASTStoreViewControllerTableViewCellTagBottomLineView];
        
        if( nil == topLineView )
        {   
            CGRect frame = backgroundView.frame;
            frame.size.height = 1;
            
            topLineView = [[[UIView alloc] initWithFrame:frame] autorelease];
            topLineView.tag = ASTStoreViewControllerTableViewCellTagTopLineView;
            topLineView.backgroundColor = [UIColor whiteColor];
            [backgroundView addSubview:topLineView];
        }
        
        if( nil == bottomLineView )
        {   
            CGRect frame = backgroundView.frame;
            frame.origin.y = frame.size.height - 1.0;
            frame.size.height = 1.0;
            
            bottomLineView = [[[UIView alloc] initWithFrame:frame] autorelease];
            bottomLineView.tag = ASTStoreViewControllerTableViewCellTagBottomLineView;
            bottomLineView.backgroundColor = [UIColor blackColor];
            [backgroundView addSubview:bottomLineView];
        }
        
        topLineView.alpha = 0.3;
        bottomLineView.alpha = 0.3;

        if( indexPath.row == 0 )
        {
            topLineView.alpha = 0.0;
        }
        else if ( indexPath.row == [self.productIdentifiers count] - 1 )
        {
            bottomLineView.alpha = 0.0;
        }
    }
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{    
    NSString *identifier = [self.productIdentifiers objectAtIndex:indexPath.row];
    ASTStoreProduct *product = [self.storeController storeProductForIdentifier:identifier];
    BOOL isPurchased = [self.storeController isProductPurchased:identifier];
    
    
    UIImageView *imageView = (UIImageView*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagImageView];
    UILabel *title = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagTitleLabel];
    UILabel *description = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagDescriptionLabel];
    UILabel *extraInfo = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagExtraInfoLabel];
    UILabel *price = (UILabel*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagPriceLabel];
    
    title.text = product.localizedTitle;
    extraInfo.text = product.extraInformation;
    
    if( product.type == ASTStoreProductIdentifierTypeConsumable )
    {
        NSUInteger onHand = [self.storeController availableQuantityForProduct:identifier];
        
        NSString *availableQuantityString = [NSString stringWithFormat:@"On Hand: %u",  onHand];
        description.text = availableQuantityString;
        price.text = product.localizedPrice;
        
        return;
    }
    else if( product.type == ASTStoreProductIdentifierTypeNonconsumable )
    {
        imageView.image = [UIImage imageNamed:@"default-nonconsumable-image"];
    }
    
    if( isPurchased )
    {
        price.text = nil;
        description.text = @"Purchased - Thank you!";
    }
    else
    {
        price.text = product.localizedPrice;
        description.text = nil;
    }
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ASTStoreTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"ASTStoreTableViewCell" owner:self options:nil];
        cell = storeCell_;
        self.storeCell = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        // Setup rounded corners
        UIImageView *imageView = (UIImageView*) [cell viewWithTag:ASTStoreViewControllerTableViewCellTagImageView];
        imageView.layer.cornerRadius = 10.0; // Same as the radius that iOS uses
        imageView.layer.masksToBounds = YES;
        
        UIView *dropShadowView = [cell viewWithTag:ASTStoreViewControllerTableViewCellTagDropShadowView];
        dropShadowView.layer.cornerRadius = 10.0;
        dropShadowView.layer.masksToBounds = NO;
        dropShadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        dropShadowView.layer.shadowOffset = CGSizeMake(0,2);
        dropShadowView.layer.shadowRadius = 1;
        dropShadowView.layer.shadowOpacity = 1;
        dropShadowView.layer.shouldRasterize = YES;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ( 67.0 );
}
       
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASTStoreDetailViewController *vc = [[[ASTStoreDetailViewController alloc] init] autorelease];
    NSString *identifier = [self.productIdentifiers objectAtIndex:indexPath.row];

    vc.productIdentifier = identifier;
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark ASTStoreControllerDelegate Methods

- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state
{
    DLog(@"stateChanged:%d", state);
    
    // Update table now that the state of the data has changed
    [self.tableView reloadData];
    [self updateStoreStateDisplay];
}

- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier
{
    DLog(@"purchased:%@", productIdentifier);
    [self.tableView reloadData];
    [self updateStoreStateDisplay];
}

- (void)astStoreControllerPurchaseStateChanged:(ASTStoreControllerPurchaseState)state
{
    DLog(@"purchaseStateChanged:%d", state);
    [self updateStoreStateDisplay];
}

// Additionally will invoke this once the restore queue has been processed
- (void)astStoreControllerRestoreComplete
{
    DLog(@"restore Complete");
    [self updateStoreStateDisplay];
}

// Failures during the restore
- (void)astStoreControllerRestoreFailedWithError:(NSError*)error
{
    DLog(@"restore failed with error:%@", error);
    self.restoreDidFail = YES;
    // No need to invoke the state update as the purchase state will change and that invokes the
    // update to the display 
}

- (void)astStoreControllerProductIdentifierExpired:(NSString*)productIdentifier
{
    DLog(@"product identifier expired:%@", productIdentifier);
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    switch ([alertView tag]) {
        case 0:
            if (buttonIndex == 1) {                
                ASTWebViewController *targetViewController = [[ASTWebViewController alloc] initWithNibName:(isAniPad ? @"ASTWebView-iPad" : @"ASTWebView") bundle:nil];
                targetViewController.location = [NSURL URLWithString:@"http://anystonetech.com"];
               [self presentModalViewController:targetViewController animated:YES];
                targetViewController.theTitle.text = @"Anystone";
                [targetViewController release];
            }
            break;            
        default:
            break;
    }
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dismissView:(id)sender 
{
    [self.delegate astStoreViewControllerDidFinish:self];
}

- (void)infoView:(id)sender 
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Powered By:"
                                                    message:@"Anystone Technologies\nASTStoreKit"
                                                   delegate:self cancelButtonTitle:@"Close" 
                                          otherButtonTitles:@"More...", nil];
    [alert setTag:0];
    [alert show];
    [alert release];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    infoButton.frame = CGRectMake(0, 0, 51.0, 29.0);
    [infoButton addTarget:self action:@selector(infoView:) forControlEvents:UIControlEventTouchUpInside];    
    [infoButton setImage:[UIImage imageNamed:@"storekit_navbar_button_black_effect.png"] forState:UIControlStateNormal];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setLeftBarButtonItem:modalButton animated:YES];
    [modalButton release];
        
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self
                                               action:@selector(dismissView:)] autorelease];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    self.storeController.delegate = self;
        
    [self.storeController requestProductDataFromiTunes:NO];
    [self updateStoreStateDisplay];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.storeController.delegate = nil;    
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.title = @"AST Store";
		isAniPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableContainerView = nil;
    self.tableView = nil;
    self.storeCell = nil;
    self.restorePreviousPurchaseButton = nil;
    self.connectingToStoreLabel = nil;
    self.connectingActivityIndicatorView = nil;
}

#pragma  mark - Memory Management

- (void)dealloc
{
    
    [productIdentifiers_ release], productIdentifiers_ = nil;
    
    [tableContainerView_ release];
    tableContainerView_ = nil;
    
    [tableView_ release];
    tableView_ = nil;
    
    [storeCell_ release];
    storeCell_ = nil;

    [restorePreviousPurchaseButton_ release];
    restorePreviousPurchaseButton_ = nil;

    [connectingToStoreLabel_ release];
    connectingToStoreLabel_ = nil;
    
    [connectingActivityIndicatorView_ release];
    connectingActivityIndicatorView_ = nil;
    
    self.storeController.delegate = nil;
    
    delegate = nil;
    
    [cellBackgroundColor1_ release], cellBackgroundColor1_ = nil;
    [cellBackgroundColor2_ release], cellBackgroundColor2_ = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
