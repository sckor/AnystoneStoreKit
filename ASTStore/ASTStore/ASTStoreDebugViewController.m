//
//  ASTStoreDebugViewController.m
//  ASTStore
//
//  Created by Sean Kormilo on 11-05-06.
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
    return YES;
}

@end
