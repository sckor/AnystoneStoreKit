//
//  ASTStoreDetailViewController.m
//  ASTStore
//
//  Created by Sean Kormilo on 11-03-16.
//  http://www.anystonetech.com

//  Voucher Sharing developed by Gregory Meach on 11-05-02.
//  http://meachware.com
//  Copyright (c) 2010 Gregory Meach, MeachWare.

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
#import "ASTStoreViewController.h"
#import "UIImageView+ReflectedImage.h"
#import "UIView+SimpleLayerGradient.h"

@interface ASTStoreDetailViewController ()

@property (readonly) ASTStoreController *storeController;
@property (readonly,retain) ASTStoreProduct *storeProduct;

@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *peerID;

- (void)invalidateSession:(GKSession *)session;
- (void)cancelShare;

@end

@implementation ASTStoreDetailViewController

@synthesize gradientView;
@synthesize titleView;
@synthesize purchaseImage = purchaseImage_;
@synthesize productTitle = productTitle_;
@synthesize description = description_;
@synthesize extraInfo = extraInfo_;
@synthesize purchaseButton = purchaseButton_;
@synthesize storeController;
@synthesize storeProduct = storeProduct_;
@synthesize productIdentifier = productIdentifier_;
@synthesize onHand = onHand_;
@synthesize reflectionImageView;

@synthesize session = _session;
@synthesize peerID = _peerID;
@synthesize sliderAlert;


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
    self.productTitle.text = [self.storeProduct localizedTitle];
    self.description.text = [self.storeProduct localizedDescription];
    self.extraInfo.text = self.storeProduct.extraInformation;
    
    NSString *purchaseTitle = nil;
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    
    if( [self.storeController isProductPurchased:self.productIdentifier] )
    {
        purchaseTitle = NSLocalizedString(@"Purchased - Thank You!", nil);
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
                purchaseTitle = [NSString stringWithFormat:NSLocalizedString(@"Only %@", @"Only %@"), [self.storeProduct localizedPrice]];
            }
            self.purchaseButton.enabled = YES;
        }
        else
        {
            purchaseTitle = NSLocalizedString(@"Store Error", nil);
            self.purchaseButton.enabled = NO;
        }
    }
    else
    {
        purchaseTitle = NSLocalizedString(@"Connecting to Store", nil);
        self.purchaseButton.enabled = NO;
    }
 
        
    if( self.storeProduct.type == ASTStoreProductIdentifierTypeConsumable )
    {
        int amount = [self.storeController availableQuantityForProduct:self.productIdentifier];
        self.onHand.text = [NSString stringWithFormat:NSLocalizedString(@"On Hand: %d", @"On Hand: %d"),amount];
        if (amount > 0) {
            self.navigationItem.rightBarButtonItem.enabled = TRUE;
            NSLog(@"Share Enabled");
        }
    }
    else
    {
        self.onHand.text = nil;
    }
        
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateNormal];
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateHighlighted];
}


#pragma mark Actions

- (IBAction)purchaseButtonPressed:(id)sender 
{
    [self.storeController purchaseProduct:self.productIdentifier];
}

#pragma mark Voucher Actions

-(void)promptForQty 
{
	int amount = [self.storeController availableQuantityForProduct:self.productIdentifier];
    NSString * message = [NSString stringWithFormat:@"How many vouchers do you want to transfer?\n\n\n\n"];
    sliderAlert = [[AlertSliderWindow alloc] initWithTitle:@"Share Voucher"
                                                   yoffset:0
                                                  setValue:amount
                                                  minValue:1
                                                  maxValue:amount
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                             okButtonTitle:@"Transmit"];
	
	[sliderAlert setTag:1];
    [sliderAlert show];
	[sliderAlert release];
}
-(void)showShareNotice
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voucher Sharing" 
                                                    message:@"Please launch \"Receive Voucher\" on your other iOS device.\nTap \"Connect\" when ready." 
                                                   delegate:self 
                                          cancelButtonTitle:@"Abort" 
                                          otherButtonTitles:@"Connect",nil];
    [alert setTag:2];
    [alert show];
    [alert release];    
}
-(void)launchConnect 
{
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    [picker show];    
}

- (void)sendVoucherWithQty:(int)qty {    
    if (self.session != nil) {
        NSDictionary *packetDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          kReceiveKey, @"key", 
                                          [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey], @"version", 
                                          [UIDevice currentDevice].name, @"sender", 
                                          [self.storeProduct localizedTitle], @"message",
                                          self.productIdentifier, @"prodID",
                                          [NSNumber numberWithInt:qty], @"qty",
                                          nil];
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:packetDictionary];
        NSMutableData *packetData = [[NSMutableData alloc] init];
        
        int packetLength = archivedData.length;
        
        [packetData appendBytes:&packetLength length:sizeof(int)];
        [packetData appendData:archivedData];        
        
        [self.session sendData:packetData 
                       toPeers:[NSArray arrayWithObjects:self.peerID, nil] 
                  withDataMode:GKSendDataReliable 
                         error:nil];
        
        [packetData release];
    }
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate methods
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type 
{    
    GKSession *theSession = [[GKSession alloc] initWithSessionID:kSessionID displayName:nil sessionMode:GKSessionModePeer]; 
    return [theSession autorelease];             
}
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)thePeerID toSession:(GKSession *)theSession 
{    
	self.session = theSession;
	self.session.delegate = self; 
    self.peerID = thePeerID; 
    
	[self.session setDataReceiveHandler:self withContext:NULL];
	
	[picker dismiss];
	picker.delegate = nil;
	[picker release];
}
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(self.session != nil)	{
		[self invalidateSession:self.session];
	}
} 

#pragma mark -
#pragma mark GKSessionDelegate methods
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID 
{
    NSLog(@"peerID:%@",[session displayNameForPeer:peerID]);
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state 
{
    NSLog(@"didChangeState was called from peerID: %@.", peerID);    
    
    switch (state) {			
		case GKPeerStateAvailable:
            // A peer became available by starting app, exiting settings, or ending a call.
			break;
		case GKPeerStateUnavailable:
            // Peer is unavailable
			break;
        case GKPeerStateConnected:
            NSLog(@"Peer %@ Connected", self.peerID);            
            [self performSelector:@selector(promptForQty) withObject:self afterDelay:0.5];
            break;			
        case GKPeerStateDisconnected:
            NSLog(@"Peer %@ Disconnected", self.peerID);
            break;  
        case GKPeerStateConnecting:
            // Peer is attempting to connect to the session.
            break;
    }
}

- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler:nil withContext:NULL]; 
		session.delegate = nil; 
		self.session = nil;
	}
}

-(void)cancelShare 
{
    [self invalidateSession:self.session];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"receiveData was called");    
    int length;
    [data getBytes:&length length:sizeof(int)];
    
    if (length == data.length - sizeof(int)) {
        uint8_t packetData[length];
        
        [data getBytes:packetData range:NSMakeRange(sizeof(int), length)];
        NSDictionary *packet = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:packetData length:length]];
        
        NSString *key = [packet objectForKey:@"key"];
        NSString *message = [packet objectForKey:@"message"];
        int qty = [[packet objectForKey:@"qty"]intValue];
        if ([key isEqualToString:kTransmitKey]) {
            NSString *messageText = [NSString stringWithFormat:@"%@\nQty Sent: %i",message,qty];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" 
                                                            message:messageText 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Dismiss" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            [[ASTStoreController sharedStoreController]consumeProduct:self.productIdentifier quantity:qty];
            [self updateViewData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure!" 
                                                            message:message //@"Transfer incomplete, please retry." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Dismiss" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];            
        }
        [self performSelector:@selector(cancelShare) withObject:self afterDelay:0.8];
    }
}

#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch ([alertView tag]) {
        case 1: // transmit
            if (buttonIndex == 1) {
                int val = (int)[[sliderAlert alertSlider]value];
                [self sendVoucherWithQty:val];
            } else
                [self cancelShare];
            break;
        case 2: // Connect info
            if (buttonIndex == 1) {
                [self performSelector:@selector(launchConnect) withObject:self afterDelay:0.5];
            }
            break;
        default:
            break;
    }
	
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [self.purchaseButton useBlueConfirmStyle];
    self.purchaseImage.layer.cornerRadius = 10.0; // Same as the radius that iOS uses
    self.purchaseImage.layer.masksToBounds = YES;
    
    self.reflectionImageView.layer.cornerRadius = 10.0;
    self.reflectionImageView.layer.masksToBounds = YES;
    
    self.title = self.storeProduct.title;
    
    if (( self.storeProduct.type == ASTStoreProductIdentifierTypeConsumable ) && ([[ASTStoreController sharedStoreController] voucherSharingEnabled] )) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Share" 
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(showShareNotice)] autorelease];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewData];

    [self.gradientView setSimpleLayerGradient:[UIColor colorWithWhite:0.5 alpha:1.0] 
                                     endColor:[UIColor lightGrayColor]];
    
    self.purchaseImage.image = self.storeProduct.productImage;

    self.reflectionImageView.image = [self.purchaseImage reflectedImageWithHeight:14.0];
    self.reflectionImageView.alpha = 0.4;    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    
    [self setReflectionImageView:nil];
    [self setTitleView:nil];
    [self setGradientView:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    
    [storeProduct_ release], storeProduct_ = nil;
    [purchaseImage_ release];
    [productTitle_ release];
    [description_ release];
    [extraInfo_ release];
    [purchaseButton_ release];
    [productIdentifier_ release];    
    [onHand_ release];
    
    [reflectionImageView release];
    [titleView release];
    [gradientView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}


@end
