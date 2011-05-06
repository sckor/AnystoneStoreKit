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


#import "ASTStoreViewController.h"
#import "ASTStoreDetailViewController.h"
#import "ASTWebViewController.h"


@interface ASTStoreViewController()

@property (readonly) ASTStoreController *storeController;
@property (nonatomic,retain) NSArray *productIdentifiers;
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
@synthesize removeAllPurchaseButton = removeAllPurchaseButton_;


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


#pragma mark User Interface

- (IBAction)restorePreviousPurchaseButtonPressed:(id)sender
{
    [self.storeController restorePreviousPurchases];
}



- (void)updateStoreStateDisplay
{
    switch ( self.storeController.productDataState ) 
    {            
        case ASTStoreControllerProductDataStateUpdating:
            self.connectingToStoreLabel.text = @"Connecting to Store";
            [self.connectingActivityIndicatorView startAnimating];
            break;
            
        case ASTStoreControllerProductDataStateUpToDate:
            self.connectingToStoreLabel.text = nil;
            self.productIdentifiers = nil;
            [self.tableView reloadData];
            [self.connectingActivityIndicatorView stopAnimating];
            break;
            
        case ASTStoreControllerProductDataStateUnknown:
        case ASTStoreControllerProductDataStateStale:
        case ASTStoreControllerProductDataStateStaleTimeout:
        default:
            self.connectingToStoreLabel.text = @"Store Not Available";
            [self.connectingActivityIndicatorView stopAnimating];
            break;
    }
    
    switch ( self.storeController.purchaseState ) 
    {
        case ASTStoreControllerPurchaseStateProcessingPayment:
            self.connectingToStoreLabel.text = @"Processing";
            [self.connectingActivityIndicatorView startAnimating];
            break;

        case ASTStoreControllerPurchaseStateVerifyingReceipt:
            self.connectingToStoreLabel.text = @"Verifying";
            [self.connectingActivityIndicatorView startAnimating];
            break;
            
        case ASTStoreControllerPurchaseStateDownloadingContent:
            self.connectingToStoreLabel.text = @"Downloading";
            [self.connectingActivityIndicatorView startAnimating];
            break;

        default:
            break;
    }
}


#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ( [self.productIdentifiers count] );
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{    
    NSString *identifier = [self.productIdentifiers objectAtIndex:indexPath.row];
    ASTStoreProduct *product = [self.storeController storeProductForIdentifier:identifier];
    BOOL isPurchased = [self.storeController isProductPurchased:identifier];
    
    
    //UIImageView *imageView = (UIImageView*) [cell viewWithTag:1];
    UILabel *title = (UILabel*) [cell viewWithTag:2];
    UILabel *description = (UILabel*) [cell viewWithTag:3];
    UILabel *extraInfo = (UILabel*) [cell viewWithTag:4];
    UILabel *price = (UILabel*) [cell viewWithTag:5];
    
    title.text = product.localizedTitle;
    extraInfo.text = product.extraInformation;
    
    if( product.type == ASTStoreProductIdentifierTypeConsumable )
    {
        NSUInteger onHand = [self.storeController availableQuantityForProduct:identifier];
        
        NSString *availableQuantityString = [NSString stringWithFormat:@"On Hand: %u",  onHand];
        description.text = availableQuantityString;
        price.text = product.localizedPrice;
    }
    else
    {
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
    
    //imageView.image = nil;
    
    cell.backgroundColor = [UIColor lightGrayColor];
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
    self.connectingToStoreLabel.text = @"Restore Failed";
    
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

-(void)layoutLandscape {
    self.tableContainerView.frame = CGRectMake(160.0, 0.0, 320.0, 290.0);
    self.restorePreviousPurchaseButton.frame = CGRectMake(7.0, 25.0, 145.0, 50.0);
    self.connectingToStoreLabel.frame = CGRectMake(7.0, 115.0, 145.0, 21.0);
    self.connectingActivityIndicatorView.frame = CGRectMake(69.0, 87.0, 20.0, 20.0);
    self.removeAllPurchaseButton.frame = CGRectMake(7.0, 218.0, 145.0, 50.0);    
}
-(void)layoutPortrait {
    self.tableContainerView.frame = CGRectMake(0.0, 0.0, 320.0, 262.0);
    self.restorePreviousPurchaseButton.frame = CGRectMake(46.0, 270.0, 228.0, 37.0);
    self.connectingToStoreLabel.frame = CGRectMake(66.0, 316.0, 189.0, 21.0);
    self.connectingActivityIndicatorView.frame = CGRectMake(254.0, 317.0, 20.0, 20.0);
    self.removeAllPurchaseButton.frame = CGRectMake(46.0, 393, 228.0, 37.0);
}

#pragma mark - View lifecycle

- (void)updateThisView {
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        if (!isAniPad)
            [self layoutLandscape];
    }
	else { 
        if (!isAniPad)
            [self layoutPortrait];
    }    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self performSelector:@selector(updateThisView) withObject:nil afterDelay:0.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    [self updateThisView];
    
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
    self.removeAllPurchaseButton = nil;
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
    
    [removeAllPurchaseButton_ release];
    removeAllPurchaseButton_ = nil;

    [connectingToStoreLabel_ release];
    connectingToStoreLabel_ = nil;
    
    [connectingActivityIndicatorView_ release];
    connectingActivityIndicatorView_ = nil;
    
    self.storeController.delegate = nil;
    
    delegate = nil;
    
    [urlTextField_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
