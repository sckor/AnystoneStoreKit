//
//  ASTStoreServer.m
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-03-18.
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

#import "ASTStoreServer.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"

@interface ASTStoreServer ()

@property (readonly) NSString *bundleId;

@end

@implementation ASTStoreServer

#pragma mark Synthesizers

@synthesize serverUrl = serverUrl_;
@synthesize serverConnectionTimeout = serverConnectionTimeout_;
@synthesize bundleId = bundleId_;

#pragma mark Override Synthesized Methods

- (NSString*)bundleId
{
    if( nil != bundleId_ )
    {
        return bundleId_;
    }
    
    bundleId_ = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [bundleId_ retain];
    
    return bundleId_;
}

#pragma mark Receipt Verification

- (ASIFormDataRequest*)formDataRequestFromReceipt:(NSData*)receiptData forProductId:(NSString*)productId
{
    NSURL *receiptServiceURL = [self.serverUrl URLByAppendingPathComponent:@"service/receipt/validate"];
    //NSURL *receiptServiceURL = [self.serverUrl URLByAppendingPathComponent:@"posttttest.php"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:receiptServiceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    // Keys match Apple's JSON response definitions for consistency
    [serviceRequest setPostValue:productId forKey:@"product_id"];
    [serviceRequest setPostValue:self.bundleId forKey:@"bid"];
    
    NSString *receiptString = [ASIHTTPRequest base64forData:receiptData];
    
    [serviceRequest setPostValue:receiptString forKey:@"receipt-data"];
    
    return ( serviceRequest );
}

// Synchronous Verification
// TODO - Async Verification
- (kASTStoreServerReceiptVerificationResult)verifyReceipt:(NSData*)receiptData forProductId:(NSString*)productId
{
    // If no server URL defined, then assume verification passes
    if( nil == self.serverUrl )
    {
        return kASTStoreServerReceiptVerificationResultPass;
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestFromReceipt:receiptData forProductId:productId];
    [serviceRequest startSynchronous];
    
    NSError *error = [serviceRequest error];
    
    if( error )
    {
        // This would generally be a network error, so assume the verification passed
        // since we would not want to reject purchase if our server is down
        DLog(@"error: %@", error);
        return ( kASTStoreServerReceiptVerificationResultInconclusive );
    }
    
   
    // Need to decode response.... JSON format...
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:[serviceRequest responseData]];
    
    if( ! [responseObject isKindOfClass:[NSDictionary class]] )
    {
        // This should have been a dictionary; do nothing and assume it passed
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( kASTStoreServerReceiptVerificationResultInconclusive );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:@"status"];
    
    if( nil == status )
    {
        return ( kASTStoreServerReceiptVerificationResultInconclusive );
    }
    
    if( [status integerValue] == 0 )
    {
        // Passed
        return ( kASTStoreServerReceiptVerificationResultPass );
    }
    
    // Failed
    DLog(@"response:%@", responseDict);
    return ( kASTStoreServerReceiptVerificationResultFail );
}

#pragma mark Init/Dealloc

- (id)init 
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    serverUrl_ = nil;
    serverConnectionTimeout_ = kASTStoreServerDefaultNetworkTimeout;
    bundleId_ = nil;
    
    DLog(@"Instantiated ASTStoreServer");
    return self;
}

- (void)dealloc 
{
    [serverUrl_ release];
    serverUrl_ = nil;
    
    [bundleId_ release];
    bundleId_ = nil;
    
    [super dealloc];
}

@end
