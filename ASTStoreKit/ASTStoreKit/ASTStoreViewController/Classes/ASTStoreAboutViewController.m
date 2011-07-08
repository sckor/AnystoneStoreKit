//
//  ASTStoreAboutViewController.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-07-08.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ASTStoreAboutViewController.h"
#import "UIImageView+ReflectedImage.h"
#import "UIView+SimpleLayerGradient.h"
#import "ASTStoreViewControllerCommon.h"
#import "ASTWebViewController.h"

enum ASTStoreAboutViewControllerRows 
{
    ASTStoreAboutViewControllerRowAnystone = 0,
    ASTStoreAboutViewControllerRowReachability,
    ASTStoreAboutViewControllerRowASIHTTPRequest,
    ASTStoreAboutViewControllerRowJSONKit,
    ASTStoreAboutViewControllerRowSSKeychain,
    ASTStoreAboutViewControllerRowSimStoreKit,
    ASTStoreAboutViewControllerRowReflection,
    ASTStoreAboutViewControllerRowMBProgressHUD,
    ASTStoreAboutViewControllerRowGradientButton,
    ASTStoreAboutViewControllerRowMax
};


@implementation ASTStoreAboutViewController

@synthesize delegate = delegate_;
@synthesize gradientView;
@synthesize imageView;
@synthesize reflectionImageView;
@synthesize tableView;
@synthesize cellBackgroundColor1 = cellBackgroundColor1_;
@synthesize cellBackgroundColor2 = cellBackgroundColor2_;

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

- (void)pushWebViewWithURL:(NSURL*)aUrl andTitle:(NSString*)aTitle
{
    BOOL isAniPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    ASTWebViewController *targetViewController = [[[ASTWebViewController alloc] 
                                                  initWithNibName:(isAniPad ? @"ASTWebView-iPad" : @"ASTWebView") bundle:nil]
                                                  autorelease];
    targetViewController.location = aUrl;
    targetViewController.title = aTitle;
    [self.navigationController pushViewController:targetViewController animated:YES];
}

#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ASTStoreAboutViewControllerRowMax;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    updateCellBackgrounds(cell, indexPath, self.cellBackgroundColor1, self.cellBackgroundColor2);
}

- (NSString*)titleForRow:(NSUInteger)row
{
    switch (row)
    {
        case ASTStoreAboutViewControllerRowAnystone:
        {
            return @"Anystone";
            break;
        }
            
        case ASTStoreAboutViewControllerRowReachability:
        {            
            return @"Reachability";
            break;
        }
            
        case ASTStoreAboutViewControllerRowASIHTTPRequest:
        {            
            return @"ASIHTTPRequest";
            break;
        }
            
        case ASTStoreAboutViewControllerRowJSONKit:
        {            
            return @"JSONKit";
            break;
        }
            
        case ASTStoreAboutViewControllerRowSSKeychain:
        {            
            return @"SSKeychain";
            break;
        }
            
        case ASTStoreAboutViewControllerRowSimStoreKit:
        {            
            return @"SimStoreKit";
            break;
        }
            
        case ASTStoreAboutViewControllerRowReflection:
        {            
            return @"Reflection";            
            break;
        }
            
        case ASTStoreAboutViewControllerRowMBProgressHUD:
        {            
            return @"MBProgressHUD";            
            break;
        }
            
        case ASTStoreAboutViewControllerRowGradientButton:
        {            
            return @"GradientButtons";
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (void)configureCell:(UITableViewCell*)aCell forRow:(NSUInteger)row
{
    aCell.textLabel.text = [self titleForRow:row];
    
    switch (row) 
    {
        case ASTStoreAboutViewControllerRowAnystone:
        {
            aCell.detailTextLabel.text = @"Copyright © 2011, Anystone Technologies";
            break;
        }

        case ASTStoreAboutViewControllerRowReachability:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2010, Apple Inc.";
            break;
        }

        case ASTStoreAboutViewControllerRowASIHTTPRequest:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2007-2011, All-Seeing Interactive.";
            break;
        }

        case ASTStoreAboutViewControllerRowJSONKit:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2011, John Engelhart.";
            break;
        }

        case ASTStoreAboutViewControllerRowSSKeychain:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2010-2011, Sam Soffes.";
            break;
        }

        case ASTStoreAboutViewControllerRowSimStoreKit:
        {            
            aCell.detailTextLabel.text = @"Public Domain";            
            break;
        }

        case ASTStoreAboutViewControllerRowReflection:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2010, Apple Inc.";
            break;
        }

        case ASTStoreAboutViewControllerRowMBProgressHUD:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2011, Matej Bukovinski.";  
            break;
        }

        case ASTStoreAboutViewControllerRowGradientButton:
        {            
            aCell.detailTextLabel.text = @"Copyright © 2010, Jeff LaMarche.";
            break;
        }

        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ASTStoreAboutTableViewCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        cell.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell forRow:indexPath.row];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *aTitle = [self titleForRow:indexPath.row];
    NSString *urlString = nil;
    NSURL *aURL = nil;
    
    switch (indexPath.row) 
    {
        case ASTStoreAboutViewControllerRowAnystone:
        {
            urlString = @"http://www.anystonetech.com";
            break;
        }
            
        case ASTStoreAboutViewControllerRowReachability:
        {      
            urlString = @"http://developer.apple.com/library/ios/samplecode/Reachability/index.html";
            break;
        }
            
        case ASTStoreAboutViewControllerRowASIHTTPRequest:
        {            
            urlString = @"http://allseeing-i.com/ASIHTTPRequest";
            break;
        }
            
        case ASTStoreAboutViewControllerRowJSONKit:
        {
            urlString = @"http://github.com/johnezang/JSONKit";
            break;
        }
            
        case ASTStoreAboutViewControllerRowSSKeychain:
        { 
            urlString = @"http://github.com/samsoffes/sskeychain";
            break;
        }
            
        case ASTStoreAboutViewControllerRowSimStoreKit:
        {
            urlString = @"http://github.com/millenomi/simstorekit";
            break;
        }
            
        case ASTStoreAboutViewControllerRowReflection:
        {
            urlString = @"http://developer.apple.com/library/ios/#samplecode/Reflection/Introduction/Intro.html";
            break;
        }
            
        case ASTStoreAboutViewControllerRowMBProgressHUD:
        {
            urlString = @"http://github.com/matej/MBProgressHUD";
            break;
        }
            
        case ASTStoreAboutViewControllerRowGradientButton:
        {
            urlString = @"http://iphonedevelopment.blogspot.com/2010/05/programmatic-gradient-buttons.html";
            break;
        }
            
        default:
            break;
    }

    aURL = [NSURL URLWithString:urlString];
    [self pushWebViewWithURL:aURL andTitle:aTitle];
}

- (void)dealloc
{
    delegate_ = nil;
    
    [cellBackgroundColor1_ release], cellBackgroundColor1_ = nil;
    [cellBackgroundColor2_ release], cellBackgroundColor2_ = nil;
    
    [gradientView release];
    [imageView release];
    [reflectionImageView release];
    [tableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.layer.cornerRadius = 10.0; // Same as the radius that iOS uses
    self.imageView.layer.masksToBounds = YES;
    
    self.reflectionImageView.layer.cornerRadius = 10.0;
    self.reflectionImageView.layer.masksToBounds = YES;
    
    self.title = NSLocalizedString(@"About", nil);
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self
                                               action:@selector(doneButtonPressed:)] autorelease];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                     endColor:[UIColor lightGrayColor]];
    
    self.imageView.image = [UIImage imageNamed:@"AnystoneStoreKitLogo"];
    
    self.reflectionImageView.image = [self.imageView reflectedImageWithHeight:14.0];
    self.reflectionImageView.alpha = 0.4;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidUnload
{
    [self setGradientView:nil];
    [self setImageView:nil];
    [self setReflectionImageView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)doneButtonPressed:(id)sender 
{
    [self.delegate astStoreViewControllerDidFinish:self];
}

- (IBAction)anystoneButtonPressed:(id)sender 
{
    NSURL *url = [NSURL URLWithString:@"http://www.anystonetech.com/"];
    [self pushWebViewWithURL:url andTitle:@"Anystone"];
}

@end
