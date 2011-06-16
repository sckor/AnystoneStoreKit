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
#import "ASTStoreConfigKeys.h"

#define kDefaultServiceURLReceiptValidation @"service/receipt/validate"
#define kDefaultServiceURLPromoCodeValidation @"service/purchase/validate"
#define kDefaultServiceURLProductQuery @"service/product/query"
#define kDefaultServiceURLProductList @"service/product/list"
#define kDefaultServiceURLSubscriptionValidation @"service/subscription/validate"

@interface ASTStoreServer ()

@property (readonly) NSString *bundleId;
@property (readonly) NSString *udid;
@property (nonatomic, copy) NSString *serviceURLPathReceiptValidation;
@property (nonatomic, copy) NSString *serviceURLPathPromoCodeValidation;
@property (nonatomic, copy) NSString *serviceURLPathProductQuery;
@property (nonatomic, copy) NSString *serviceURLPathProductList;
@property (nonatomic, copy) NSString *serviceURLPathSubscriptionValidation;

@end

@implementation ASTStoreServer


#pragma mark Synthesizers

@synthesize serverUrl = serverUrl_;
@synthesize serverConnectionTimeout = serverConnectionTimeout_;
@synthesize bundleId = bundleId_;
@synthesize udid = udid_;
@synthesize vendorUuid = vendorUuid_;
@synthesize serviceURLPathReceiptValidation = serviceURLPathReceiptValidation_;
@synthesize serviceURLPathPromoCodeValidation = serviceURLPathPromoCodeValidation_;
@synthesize serviceURLPathProductQuery = serviceURLPathProductQuery_;
@synthesize serviceURLPathProductList = serviceURLPathProductList_;
@synthesize serviceURLPaths = serviceURLPaths_;
@synthesize serviceURLPathSubscriptionValidation = serviceURLPathSubscriptionValidation_;
@synthesize sharedSecret = sharedSecret_;

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

- (NSString*)serviceURLPathProductList
{
    if( nil != serviceURLPathProductList_ )
    {
        ASTReturnRA( serviceURLPathProductList_ );
    }
    
    NSString *servicePath = kDefaultServiceURLProductList;
    
    if( nil != self.serviceURLPaths )
    {
        NSString *tmpPath = [self.serviceURLPaths objectForKey:kASTStoreConfigServiceURLProductListKey];
        if( nil != tmpPath )
        {
            // A value was set in the dictionary so use that instead
            servicePath = tmpPath;
        }
    }

    self.serviceURLPathProductList = servicePath;
    
    ASTReturnRA( serviceURLPathProductList_ );
}

- (NSString*)serviceURLPathProductQuery
{
    if( nil != serviceURLPathProductQuery_ )
    {
        ASTReturnRA( serviceURLPathProductQuery_ );
    }
    
    NSString *servicePath = kDefaultServiceURLProductQuery;
    
    if( nil != self.serviceURLPaths )
    {
        NSString *tmpPath = [self.serviceURLPaths objectForKey:kASTStoreConfigServiceURLProductQueryKey];
        if( nil != tmpPath )
        {
            // A value was set in the dictionary so use that instead
            servicePath = tmpPath;
        }
    }
    
    self.serviceURLPathProductQuery = servicePath;
    
    ASTReturnRA( serviceURLPathProductQuery_ );    
}

- (NSString*)serviceURLPathPromoCodeValidation
{
    if( nil != serviceURLPathPromoCodeValidation_ )
    {
        ASTReturnRA( serviceURLPathPromoCodeValidation_ );
    }
    
    NSString *servicePath = kDefaultServiceURLPromoCodeValidation;
    
    if( nil != self.serviceURLPaths )
    {
        NSString *tmpPath = [self.serviceURLPaths objectForKey:kASTStoreConfigServiceURLPromoCodeValidationKey];
        if( nil != tmpPath )
        {
            // A value was set in the dictionary so use that instead
            servicePath = tmpPath;
        }
    }
    
    self.serviceURLPathPromoCodeValidation = servicePath;
    
    ASTReturnRA( serviceURLPathPromoCodeValidation_ );    
}

- (NSString*)serviceURLPathReceiptValidation
{
    if( nil != serviceURLPathReceiptValidation_ )
    {
        ASTReturnRA( serviceURLPathReceiptValidation_ );
    }
    
    // Default to the default by default - ha ha!
    NSString *servicePath = kDefaultServiceURLReceiptValidation;
    
    // See if a dictionary has been set for the service URL paths
    if( nil != self.serviceURLPaths )
    {
        NSString *tmpPath = [self.serviceURLPaths objectForKey:kASTStoreConfigServiceURLReceiptValidationKey];
        if( nil != tmpPath )
        {
            // A value was set in the dictionary so use that instead
            servicePath = tmpPath;
        }
    }

    self.serviceURLPathReceiptValidation = servicePath;
    
    ASTReturnRA( serviceURLPathReceiptValidation_ );    
}

- (NSString*)serviceURLPathSubscriptionValidation
{
    if( nil != serviceURLPathSubscriptionValidation_ )
    {
        ASTReturnRA( serviceURLPathSubscriptionValidation_ );
    }
    
    // Default to the default by default - ha ha!
    NSString *servicePath = kDefaultServiceURLSubscriptionValidation;
    
    // See if a dictionary has been set for the service URL paths
    if( nil != self.serviceURLPaths )
    {
        NSString *tmpPath = [self.serviceURLPaths objectForKey:kASTStoreConfigServiceURLSubscriptionValidationKey];
        if( nil != tmpPath )
        {
            // A value was set in the dictionary so use that instead
            servicePath = tmpPath;
        }
    }
    
    self.serviceURLPathSubscriptionValidation = servicePath;
    
    ASTReturnRA( serviceURLPathSubscriptionValidation_ );    
}

#pragma mark Receipt Verification
- (ASTStoreServerResult)verifySubscriptionReceipt:(NSString*)receiptBase64Data 
                           expiresDate:(NSDate**)expiresDate 
              latestReceiptBase64Data:(NSString**)latestReceiptBase64Data
{
    NSString *receiptServer = nil;
    NSString *receiptServicePath = nil;
    
    // If there is no server URL then a sharedSecret must be supplied here
    // If there is a server URL then log a warning if a shared secret is passed in, since we should
    // rely on the server for managing the shared secret
    if(( nil == self.serverUrl ) && ( nil != self.sharedSecret ))
    {
#ifdef DEBUG
        receiptServer = @"https://sandbox.itunes.apple.com";
#else
        receiptServer = @"https://buy.itunes.apple.com";        
#endif
        
        receiptServicePath = @"verifyReceipt";
    }
    else if(( nil != self.serverUrl ) && ( nil != self.sharedSecret ))
    {
        DLog(@"WARNING: It is recommended that shared secrets not be embedded in the application");
        receiptServer = [self.serverUrl absoluteString];
        receiptServicePath = self.serviceURLPathSubscriptionValidation;
    }
    else if(( nil == self.serverUrl ) && ( nil == self.sharedSecret ))
    {
        DLog(@"CANNOT VERIFY RECEIPT: need one of a server URL or a shared secret");
        return ASTStoreServerResultFail;
    }
    
    NSURL *serviceURL = [[NSURL URLWithString:receiptServer] URLByAppendingPathComponent:receiptServicePath];
    DLog(@"serviceURL:%@", serviceURL);
    
    
    ASIHTTPRequest *serviceRequest = [ASIHTTPRequest requestWithURL:serviceURL];
    [ASIHTTPRequest setDefaultTimeOutSeconds:self.serverConnectionTimeout];
    
    NSMutableDictionary *receiptDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:receiptBase64Data, @"receipt-data", nil];
    
    if( nil != self.sharedSecret )
    {
        [receiptDictionary setObject:self.sharedSecret forKey:@"password"];
    }
        
    NSData *receiptAsJSONData = [receiptDictionary JSONData];
    
    [serviceRequest setPostBody:[receiptAsJSONData mutableCopy]];
    
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
    
    NSData *responseData = [serviceRequest responseData];
    if( nil == responseData )
    {
        DLog(@"Did not receive any data for response");
        return ( ASTStoreServerResultInconclusive );
    }
    
    JSONDecoder *decoder = [JSONDecoder decoder];
    id responseObject = [decoder objectWithData:responseData];
    
    if( ! [responseObject isKindOfClass:[NSDictionary class]] )
    {
        DLog(@"Unexpected class on decode from JSONKit: %@", NSStringFromClass([responseObject class]));
        return ( ASTStoreServerResultFail );
    }
    
    NSDictionary *responseDict = responseObject;
    
    NSNumber *status = [responseDict objectForKey:kASTStoreProductInfoStatusKey];
    
    if( nil == status )
    {
        return ( ASTStoreServerResultFail );
    }
    
    NSInteger statusAsInt = [status integerValue];
    
    switch (statusAsInt) 
    {
        case 0: // valid subscription
        {
            *latestReceiptBase64Data = [responseDict objectForKey:@"latest_receipt"];
            NSDictionary *latestReceiptInfoDict = [responseDict objectForKey:@"latest_receipt_info"];
            
            if( nil == latestReceiptInfoDict )
            {
                DLog(@"Could not find receipt info from JSON response");
                return ( ASTStoreServerResultInconclusive );
            }
            
            NSString *expiresString = [latestReceiptInfoDict objectForKey:@"expires_date"];
            if( nil == expiresString )
            {
                DLog(@"Could not find expiry date info from JSON response");
                return ( ASTStoreServerResultInconclusive );                
            }
            
            NSTimeInterval expiryAsInterval = [expiresString doubleValue];
            expiryAsInterval /= 1000; // convert from milliseconds to seconds
            
            NSDate *expiryAsDate = [NSDate dateWithTimeIntervalSince1970:expiryAsInterval];
            
            DLog(@"Subscription Active date:%@", expiryAsDate);
            *expiresDate = expiryAsDate;
            
            return ASTStoreServerResultPass;
            break;
        }
            
        case 21006:
        {
            DLog(@"This receipt is valid but the subscription has expired.");
            
            NSDictionary *latestReceiptInfoDict = [responseDict objectForKey:@"latest_expired_receipt_info"];
            
            if( nil == latestReceiptInfoDict )
            {
                DLog(@"Could not find receipt info from JSON response");
                // In this case return fail since we know the subscription has expired
                // So there is no point in giving the benefit of the doubt
                return ( ASTStoreServerResultFail );
            }
            
            NSString *expiresString = [latestReceiptInfoDict objectForKey:@"expires_date"];
            NSDate *expiryAsDate = nil;
            if( nil != expiresString )
            {
                NSTimeInterval expiryAsInterval = [expiresString doubleValue];
                expiryAsInterval /= 1000; // convert from milliseconds to seconds
                
                expiryAsDate = [NSDate dateWithTimeIntervalSince1970:expiryAsInterval];
            }
            
            DLog(@"Subscription Expired Date:%@", expiryAsDate);
            
            *expiresDate = expiryAsDate;

            return ASTStoreServerResultPass;
            break;
        }
            
        case 21005:
            DLog(@"The receipt server is not currently available.");
            return ASTStoreServerResultInconclusive;
            break;
            
        case 21000: 
            DLog(@"The App Store could not read the JSON object you provided.");
            break;
            
        case 21002:
            DLog(@"The data in the receipt-data property was malformed.");
            break;
            
        case 21003:
            DLog(@"The receipt could not be authenticated.");
            break;
            
        case 21004:
            DLog(@"The shared secret you provided does not match the shared secret on file for your account.");
            break;
            
        default:
            DLog(@"Unexpected status:%d", statusAsInt);
            break;
    }

    
    DLog(@"response:%@", responseDict);

    return ( ASTStoreServerResultFail );
}

- (void)asyncVerifySubscriptionReceipt:(NSString*)receiptBase64Data withCompletionBlock:(ASTVerifySubscriptionBlock)completionBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        NSString *latestReceipt = nil;
        NSDate *expiresDate = nil;
        
        ASTStoreServerResult result = [self verifySubscriptionReceipt:receiptBase64Data 
                                               expiresDate:&expiresDate 
                                  latestReceiptBase64Data:&latestReceipt];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(receiptBase64Data, expiresDate, latestReceipt, result);
        });
    });

}


- (ASIFormDataRequest*)formDataRequestFromReceipt:(NSData*)receiptData forProductId:(NSString*)productId
{
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:self.serviceURLPathReceiptValidation];
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
           withCompletionBlock:(ASTVerifyTransactionBlock)completionBlock
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
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:self.serviceURLPathPromoCodeValidation];
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
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:self.serviceURLPathProductQuery];
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
    NSURL *serviceURL = [self.serverUrl URLByAppendingPathComponent:self.serviceURLPathProductList];
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
    serviceURLPathProductList_ = nil;
    serviceURLPathProductQuery_ = nil;
    serviceURLPathPromoCodeValidation_ = nil;
    serviceURLPathReceiptValidation_ = nil;
    serviceURLPaths_ = nil;
    sharedSecret_ = nil;
    
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
    
    [serviceURLPathReceiptValidation_ release], serviceURLPathReceiptValidation_ = nil;
    [serviceURLPathPromoCodeValidation_ release], serviceURLPathPromoCodeValidation_ = nil;
    [serviceURLPathProductQuery_ release], serviceURLPathProductQuery_ = nil;
    [serviceURLPathProductList_ release], serviceURLPathProductList_ = nil;
    [serviceURLPaths_ release], serviceURLPaths_ = nil;
    [sharedSecret_ release], sharedSecret_ = nil;
    
    [super dealloc];
}

@end
