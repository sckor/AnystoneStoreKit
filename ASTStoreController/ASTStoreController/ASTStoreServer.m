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
@property (readonly) NSString *udid;

@end

@implementation ASTStoreServer

// Keys match Apple's JSON response definitions for consistency
static NSString * const kASTServerProductIdKey =  @"product_id";
static NSString * const kASTServerBundleIdKey =  @"bid";
static NSString * const kASTServerReceiptDataKey =  @"receipt-data";
static NSString * const kASTServerStatusKey =  @"status";
static NSString * const kASTServerUDIDKey =  @"udid";
static NSString * const kASTServerCustomerIdKey =  @"customer_id";


#pragma mark Synthesizers

@synthesize serverUrl = serverUrl_;
@synthesize serverConnectionTimeout = serverConnectionTimeout_;
@synthesize bundleId = bundleId_;
@synthesize udid = udid_;

#pragma mark private methods

#pragma mark Public Class Methods
+ (NSString*)productIdentifierForTransaction:(SKPaymentTransaction*)transaction
{
    NSString *productIdentifier = nil;
    
    if( transaction.transactionState == SKPaymentTransactionStateRestored )
    {
        productIdentifier = transaction.originalTransaction.payment.productIdentifier;
    }
    else
    {
        productIdentifier = transaction.payment.productIdentifier;
    }

    return productIdentifier;
}


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

- (NSString*)udid
{
    if( nil != udid_ )
    {
        return udid_;
    }
    
    udid_ = [[UIDevice currentDevice] uniqueIdentifier];
    [udid_ retain];
    
    return udid_;
}


#pragma mark Receipt Verification

- (ASIFormDataRequest*)formDataRequestFromReceipt:(NSData*)receiptData forProductId:(NSString*)productId
{
    NSURL *receiptServiceURL = [self.serverUrl URLByAppendingPathComponent:@"service/receipt/validate"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:receiptServiceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:productId forKey:kASTServerProductIdKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTServerBundleIdKey];
    
    NSString *receiptString = [ASIHTTPRequest base64forData:receiptData];
    
    [serviceRequest setPostValue:receiptString forKey:kASTServerReceiptDataKey];
    
    return ( serviceRequest );
}


- (ASTStoreServerResult)verifyTransaction:(SKPaymentTransaction*)transaction
{
    NSData *receiptData = transaction.transactionReceipt;
    NSString *productIdentifier = [ASTStoreServer productIdentifierForTransaction:transaction];
    
    // If no server URL defined, then assume verification passes
    if( nil == self.serverUrl )
    {
        return ASTStoreServerResultPass;
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestFromReceipt:receiptData 
                                                             forProductId:productIdentifier];
    [serviceRequest startSynchronous];
    
    NSError *error = [serviceRequest error];
    
    if( error )
    {
        // This would generally be a network error, so assume the verification passed
        // since we would not want to reject purchase if our server is down
        DLog(@"error: %@", error);
        return ( ASTStoreServerResultInconclusive );
    }
    
   
    // Need to decode response.... JSON format...
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:[serviceRequest responseData]];
    
    if( ! [responseObject isKindOfClass:[NSDictionary class]] )
    {
        // This should have been a dictionary; do nothing and assume it passed
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( ASTStoreServerResultInconclusive );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:kASTServerStatusKey];
    
    if( nil == status )
    {
        return ( ASTStoreServerResultInconclusive );
    }
    
    if( [status integerValue] == 0 )
    {
        // Passed
        return ( ASTStoreServerResultPass );
    }
    
    // Failed
    DLog(@"response:%@", responseDict);
    return ( ASTStoreServerResultFail );
}


- (void)asyncVerifyTransaction:(SKPaymentTransaction*)transaction
           withCompletionBlock:(ASTVerifyReceiptBlock)completionBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        ASTStoreServerResult result = [self verifyTransaction:transaction];
        completionBlock(transaction, result);        
    });
}


#pragma mark In App Promo Related Methods
- (ASIFormDataRequest*)formDataRequestFromProductIdentifier:(NSString*)productId andCustomerIdentifier:(NSString*)customerIdentifier
{
    NSURL *receiptServiceURL = [self.serverUrl URLByAppendingPathComponent:@"service/promo/validate"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:receiptServiceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:productId forKey:kASTServerProductIdKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTServerBundleIdKey];
    [serviceRequest setPostValue:self.udid forKey:kASTServerUDIDKey];
    
    if( nil != customerIdentifier )
    {
        [serviceRequest setPostValue:customerIdentifier forKey:kASTServerCustomerIdKey];
    }
    
    return ( serviceRequest );
}


- (BOOL)isProductPromoCodeAvailableForProductIdentifier:(NSString*)productIdentifier 
                                  andCustomerIdentifier:(NSString*)customerIdentifier
{
    // If no server URL defined, then no promo codes passes
    if( nil == self.serverUrl )
    {
        return NO;
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestFromProductIdentifier:productIdentifier andCustomerIdentifier:customerIdentifier];
    
    NSError *error = [serviceRequest error];
    
    if( error )
    {
        // This would generally be a network error, so assume failure since
        // we don't want to give away promo codes for free
        DLog(@"error: %@", error);
        return ( NO );
    }
    
    // Need to decode response.... JSON format...
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:[serviceRequest responseData]];
    
    if( ! [responseObject isKindOfClass:[NSDictionary class]] )
    {
        // This should have been a dictionary; do nothing and assume it passed
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( ASTStoreServerResultInconclusive );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:kASTServerStatusKey];
    
    if( nil == status )
    {
        return ( NO );
    }
    
    if( [status integerValue] == 0 )
    {
        // Passed
        return ( YES );
    }
    
    // Failed
    DLog(@"response:%@", responseDict);
    return ( NO );

}

- (void)asyncIsProductPromoCodeAvailableForProductIdentifier:(NSString*)productIdentifier 
                                      andCustomerIdentifier:(NSString*)customerIdentifier
                                        withCompletionBlock:(ASTProductPromoCodeBlock)completionBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        BOOL result = [self isProductPromoCodeAvailableForProductIdentifier:productIdentifier 
                                                                      andCustomerIdentifier:customerIdentifier];
        
        completionBlock(productIdentifier, customerIdentifier, result);        
    });
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
        
    [udid_ release];
    udid_ = nil;
    
    [super dealloc];
}

@end
