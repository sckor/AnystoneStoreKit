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
#import "ASTStoreProductInfoKeys.h"

@interface ASTStoreServer ()

@property (readonly) NSString *bundleId;
@property (readonly) NSString *udid;

@end

@implementation ASTStoreServer


#pragma mark Synthesizers

@synthesize serverUrl = serverUrl_;
@synthesize serverConnectionTimeout = serverConnectionTimeout_;
@synthesize bundleId = bundleId_;
@synthesize udid = udid_;
@synthesize vendorUuid = vendorUuid_;

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
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:@"service/receipt/validate"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:serviceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:productId forKey:kASTStoreProductInfoIdentifierKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTStoreProductInfoBundleIdKey];
    
    NSString *receiptString = [ASIHTTPRequest base64forData:receiptData];
    
    [serviceRequest setPostValue:receiptString forKey:kASTStoreProductInfoReceiptDataKey];
    
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
    
    NSNumber *status = [responseDict objectForKey:kASTStoreProductInfoStatusKey];
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(transaction, result);
        });
    });
}


#pragma mark In App Promo Related Methods
- (ASIFormDataRequest*)formDataRequestPromoFromProductIdentifier:(NSString*)productId andCustomerIdentifier:(NSString*)customerIdentifier
{
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:@"service/purchase/validate"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:serviceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:self.vendorUuid forKey:kASTStoreProductInfoVendorUuidKey];
    [serviceRequest setPostValue:productId forKey:kASTStoreProductInfoIdentifierKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTStoreProductInfoBundleIdKey];
    [serviceRequest setPostValue:self.udid forKey:kASTStoreProductInfoUdidKey];
    
    if( nil != customerIdentifier )
    {
        [serviceRequest setPostValue:customerIdentifier forKey:kASTStoreProductInfoCustomerIdentifierKey];
    }
    
    return ( serviceRequest );
}


- (BOOL)isProductPromoCodeAvailableForProductIdentifier:(NSString*)productIdentifier 
                                  andCustomerIdentifier:(NSString*)customerIdentifier
{
    // If no server URL defined, then no promo codes passes
    if(( nil == self.serverUrl ) || ( nil == self.vendorUuid ) || ( [self.vendorUuid isEqualToString:@""] ))
    {
        DLog(@"Unable to process request for promo code serverURL:%@ vendor:%@", self.serverUrl, self.vendorUuid);
        return NO;
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestPromoFromProductIdentifier:productIdentifier 
                                                                   andCustomerIdentifier:customerIdentifier];
    
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
    
    NSNumber *status = [responseDict objectForKey:kASTStoreProductInfoStatusKey];
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(productIdentifier, customerIdentifier, result);
        });
    });
}

#pragma mark Basic Product Data Methods
- (ASIFormDataRequest*)formDataRequestProductFromProductIdentifier:(NSString*)productId
{
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:@"service/product/query"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:serviceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:self.vendorUuid forKey:kASTStoreProductInfoVendorUuidKey];
    [serviceRequest setPostValue:productId forKey:kASTStoreProductInfoIdentifierKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTStoreProductInfoBundleIdKey];
    
    return ( serviceRequest );
}


- (ASTStoreProduct*)storeProductForProductIdentifier:(NSString*)productIdentifier
{
    // If no server URL defined, then nothing to get
    if(( nil == self.serverUrl ) || ( nil == self.vendorUuid ) || ( [self.vendorUuid isEqualToString:@""] ))
    {
        DLog(@"Unable to process request for product id serverURL:%@ vendor:%@", self.serverUrl, self.vendorUuid);
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestProductFromProductIdentifier:productIdentifier];
    
    NSError *error = [serviceRequest error];
    
    if( error )
    {
        // This would generally be a network error, so assume failure since
        // Cannot provide anything useful
        DLog(@"error: %@", error);
        return ( nil );
    }
    
    // Need to decode response.... JSON format...
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:[serviceRequest responseData]];
    
    if( ! [responseObject isKindOfClass:[NSDictionary class]] )
    {
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( nil );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:kASTStoreProductInfoStatusKey];
    
    if( nil == status )
    {
        return ( nil );
    }
    
    if( [status integerValue] != 0 )
    {
        // Failed
        return ( nil );
    }

    // TODO: Extract data from response and create StoreProduct
    

    return ( nil );
}

- (void)asyncStoreProductForProductIdentifier:(NSString*)productIdentifier
                          withCompletionBlock:(ASTStoreProductBlock)completionBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        ASTStoreProduct *result = [self storeProductForProductIdentifier:productIdentifier];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(productIdentifier, result);
        });
    });
}

- (ASIFormDataRequest*)formDataRequestProducts
{
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:@"service/product/list"];
    ASIFormDataRequest *serviceRequest = [ASIFormDataRequest requestWithURL:serviceURL];
    
    [ASIFormDataRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    [serviceRequest setPostValue:self.vendorUuid forKey:kASTStoreProductInfoVendorUuidKey];
    [serviceRequest setPostValue:self.bundleId forKey:kASTStoreProductInfoBundleIdKey];
    [serviceRequest setPostValue:self.udid forKey:kASTStoreProductInfoUdidKey];
    
    return ( serviceRequest );
}

- (NSArray*)storeProducts
{
    // If no server URL defined, then nothing to get
    if(( nil == self.serverUrl ) || ( nil == self.vendorUuid ) || ( [self.vendorUuid isEqualToString:@""] ))
    {
        DLog(@"Unable to process request for product list serverURL:%@ vendor:%@", self.serverUrl, self.vendorUuid);
        return nil;
    }
    
    ASIFormDataRequest *serviceRequest = [self formDataRequestProducts];
    
    NSError *error = [serviceRequest error];
    
    if( error )
    {
        // This would generally be a network error, so assume failure since
        // Cannot provide anything useful
        DLog(@"error: %@", error);
        return ( nil );
    }
    
    // Need to decode response.... JSON format...
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:[serviceRequest responseData]];
    
    if( ! [responseObject isKindOfClass:[NSArray class]] )
    {
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( nil );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:kASTStoreProductInfoStatusKey];
    
    if( nil == status )
    {
        return ( nil );
    }
    
    if( [status integerValue] != 0 )
    {
        // Failed
        return ( nil );
    }
    
    // TODO: Extract data from response and create StoreProducts Array
    
    
    return ( nil );
}

- (void)asyncStoreProductsWithCompletionBlock:(ASTStoreProductArrayBlock)completionBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        NSArray *result = [self storeProducts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock( result );
        });
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
    vendorUuid_ = nil;
    
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
