//
//  ASTStoreDebugViewController.m
//  ASTStore
//
//  Created by Sean Kormilo on 11-05-06.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import "ASTStoreDebugViewController.h"
#import "ASTStoreController.h"

#define kASTStoreViewControllerServerURLKey @"serverURL"
#define kASTStoreViewControllerServerEnabledKey @"serverEnabled"

@interface ASTStoreDebugViewController ()

@property (readonly) ASTStoreController *storeController;

@end

@implementation ASTStoreDebugViewController
@synthesize serverEnabledSwitch;
@synthesize urlTextField;
@synthesize removeAllPurchaseDataButton;

#pragma mark Accessors

- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (NSURL*)serverURL
{
    return ( [[NSUserDefaults standardUserDefaults] URLForKey:kASTStoreViewControllerServerURLKey] );
}

- (void)setServerURL:(NSURL*)serverURL
{
    [[NSUserDefaults standardUserDefaults] setURL:serverURL forKey:kASTStoreViewControllerServerURLKey];
}

- (BOOL)serverEnabled
{
    return ( [[NSUserDefaults standardUserDefaults] boolForKey:kASTStoreViewControllerServerEnabledKey] );
}

- (void)setServerEnabled:(BOOL)serverEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:serverEnabled forKey:kASTStoreViewControllerServerEnabledKey];
}

#pragma mark Actions

- (IBAction)removeAllPurchaseDataButtonPressed:(id)sender 
{
    [self.storeController resetAllProducts];
}

- (IBAction)serverEnabledSwitchValueChanged:(id)sender 
{
    [self setServerEnabled:self.serverEnabledSwitch.on];
    
    if( self.serverEnabledSwitch.on )
    {
        self.urlTextField.enabled = YES;
        self.storeController.serverUrl = [self serverURL];
    }
    else
    {
        self.urlTextField.enabled = NO;
        self.storeController.serverUrl = nil;
    }
}

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BOOL didChange = NO;
    
    if( [self.urlTextField.text length] == 0 )
    {
        self.storeController.serverUrl = nil;
        didChange = YES;
    }
    else if( NO == [self.urlTextField.text isEqualToString:[self.storeController.serverUrl absoluteString]] )
    {
        self.storeController.serverUrl = [NSURL URLWithString:self.urlTextField.text];
        didChange = YES;
    }
    
    if( didChange )
    {
        // Persist to NSUserDefaults
        DLog(@"Setting URL to:%@", self.storeController.serverUrl);
        [self setServerURL:self.storeController.serverUrl];
    }
}


- (void)dealloc
{
    [urlTextField release];
    [removeAllPurchaseDataButton release];
    [serverEnabledSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.serverEnabledSwitch.on = [self serverEnabled];
    if( self.serverEnabledSwitch.on )
    {
        self.storeController.serverUrl = [self serverURL];
    }
    else
    {
        self.storeController.serverUrl = nil;
    }
    
    self.urlTextField.text = [[self serverURL] absoluteString];
}

- (void)viewDidUnload
{
    [self setUrlTextField:nil];
    [self setRemoveAllPurchaseDataButton:nil];
    [self setServerEnabledSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
