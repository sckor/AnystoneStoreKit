// 
//  WebViewController.m
//
//  Created by Greg Meach on 5/6/11.
//  http://www.meachware.com

//  Copyright (c) 2011 Meachware
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

#import "ASTWebViewController.h"

@implementation ASTWebViewController

@synthesize navBar, webView, location, theTitle;

-(IBAction)closeViewAction {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)dealloc {
	[navBar release];
	[webView release];
	[location release];
	[theTitle release];
	
	[super dealloc];	
}

-(void)viewDidUnload {
	self.navBar = nil;
	self.webView = nil;
	self.location = nil;
	self.theTitle = nil;
	[super viewDidUnload];
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[webView loadRequest:[NSURLRequest requestWithURL:location]];

}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
	//	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
	//			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

@end
