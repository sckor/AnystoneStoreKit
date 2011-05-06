//
//  ASTRootViewController.m
//  ASTStore
//
//  Created by Greg Meach on 5/6/11.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import "ASTRootViewController.h"
#import "ASTStoreViewController.h"

@implementation ASTRootViewController

- (IBAction)showASTStoreBtnPressed:(id)sender
{
    if (isAniPad) {
        ASTStoreViewController *vc = [[ASTStoreViewController alloc] initWithNibName:@"ASTStoreViewController-iPad" bundle:nil];
        vc.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        navController.modalPresentationStyle = UIModalPresentationFormSheet; //Like 1/2 the size
        [self presentModalViewController:navController animated:YES];
        [navController release];
        [vc release];
	} else {
        ASTStoreViewController *vc = [[ASTStoreViewController alloc] initWithNibName:@"ASTStoreViewController" bundle:nil];
        vc.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentModalViewController:navController animated:YES];
        [navController release];
        [vc release];
	}    

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)astStoreViewControllerDidFinish:(ASTStoreViewController *)controller
{
    
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"ASTStoreViewController didDismiss");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    isAniPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
    //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
