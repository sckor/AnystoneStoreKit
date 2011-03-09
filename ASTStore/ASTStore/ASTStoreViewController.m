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

@interface ASTStoreViewController()

@property (readonly) ASTStoreController *storeController;
@property (readonly) NSArray *productIdentifiers;
@end


@implementation ASTStoreViewController

#pragma mark Synthesis

@synthesize tableContainerView = tableContainerView_;
@synthesize tableView = tableView_;
@synthesize storeCell = storeCell_;
@synthesize restorePreviousPurchaseButton = restorePreviousPurchaseButton_;
@synthesize connectingToStoreLabel = connectingToStoreLabel_;
@synthesize connectingActivityIndicatorView = connectingActivityIndicatorView_;

- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (NSArray*)productIdentifiers
{
    return ( [self.storeController productIdentifiers] );
}

#pragma mark User Interface

- (IBAction)restorePreviousPurchaseButtonPressed:(id)sender
{
    [self.storeController restorePreviousPurchases];
}

- (void)updateStoreStateDisplay
{
    switch (self.storeController.productDataState) 
    {            
        case ASTStoreControllerProductDataStateUpdating:
            self.connectingToStoreLabel.text = @"Connecting to Store";
            [self.connectingActivityIndicatorView startAnimating];
            break;
            
        case ASTStoreControllerProductDataStateUpToDate:
            self.connectingToStoreLabel.text = @"Connected to Store";
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
    
    //UIImageView *imageView = (UIImageView*) [cell viewWithTag:1];
    UILabel *title = (UILabel*) [cell viewWithTag:2];
    UILabel *description = (UILabel*) [cell viewWithTag:3];
    UILabel *extraInfo = (UILabel*) [cell viewWithTag:4];
    UILabel *price = (UILabel*) [cell viewWithTag:5];
    
    title.text = product.localizedTitle;
    description.text = product.localizedDescription;
    extraInfo.text = product.extraInformation;
    price.text = product.localizedPrice;
    
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
            
#pragma mark ASTStoreControllerDelegate Methods

- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state
{
    DLog(@"stateChanged:%d", state);
    
    // Update table now that the state of the data has changed
    [self.tableView reloadData];
    [self updateStoreStateDisplay];
}

- (void)astStoreControllerProductPurchased:(ASTStoreProduct*)storeProduct
{
    DLog(@"purchased:%@", storeProduct.productIdentifier);    
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the store delegate to the table view
    self.storeController.delegate = self;
    [self.storeController requestProductDataFromiTunes:NO];
    [self updateStoreStateDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableContainerView = nil;
    self.tableView = nil;
    self.storeController.delegate = nil;
    self.storeCell = nil;
    self.restorePreviousPurchaseButton = nil;
    self.connectingToStoreLabel = nil;
    self.connectingActivityIndicatorView = nil;

}

#pragma  mark - Memory Management

- (void)dealloc
{
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
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
