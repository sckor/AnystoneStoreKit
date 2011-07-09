//
//  ASTStoreController.m
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-03-07.
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


#import "ASTStoreController.h"
#import "ASTStoreProduct+Private.h"
#import "ASTStoreProductPlistReader.h"
#import "ASTStoreFamilyData.h"
#import "ASTStoreServer.h"
#import "ASTStoreConfigPlistReader.h"
#import "ASTStoreConfigKeys.h"
#import "ASIHTTPRequest.h"

#define kASTStoreControllerDefaultRetryStoreConnectionInterval 15.0
#define kASTStoreServerDefaultVerifyReceipts YES

@interface ASTStoreController() <SKProductsRequestDelegate, SKPaymentTransactionObserver, ASTStoreFamilyDataExpiryProtocol>

@property (readonly) NSMutableDictionary *storeProductDictionary;
@property (nonatomic) ASTStoreControllerProductDataState productDataState;
@property (retain) SKProductsRequest *skProductsRequest;
@property (readonly) SKPaymentQueue *skPaymentQueue;
@property (nonatomic) ASTStoreControllerPurchaseState purchaseState;
@property (readonly) ASTStoreServer *storeServer;
@property BOOL restoringPurchases;

@end


@implementation ASTStoreController

#pragma mark Synthesis
@synthesize storeProductDictionary = storeProductDictionary_;
@synthesize productDataState = productDataState_;
@synthesize delegate = delegate_;
@synthesize skProductsRequest = skProductsRequest_;
@synthesize skPaymentQueue;
@synthesize purchaseState = purchaseState_;
@synthesize retryStoreConnectionInterval = retryStoreConnectionInterval_;
@synthesize storeServer = storeServer_;
@synthesize verifyReceipts = verifyReceipts_;
@synthesize restoringPurchases = restoringPurchases_;
@synthesize customerIdentifier = customerIdentifier_;
@synthesize serverConsumablesEnabled = serverConsumablesEnabled_;
@synthesize serverPromoCodesEnabled = serverPromoCodesEnabled_;
@dynamic serviceURLPaths;
@dynamic sharedSecret;

+ (NSString*)version
{
    return @"v0.5.1";
}

#pragma mark Delegate Selector Stubs

- (void)invokeDelegateStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)newState
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerProductDataStateChanged:)])
    {
        [self.delegate astStoreControllerProductDataStateChanged:newState];
    }
}

- (void)invokeDelegateStoreControllerPurchaseStateChanged:(ASTStoreControllerPurchaseState)newState
{
    if (self.delegate && [self.delegate respondsToSelector: @selector(astStoreControllerPurchaseStateChanged:)])
    {
        [self.delegate astStoreControllerPurchaseStateChanged:newState];
    }
}


- (void)invokeDelegateStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerProductIdentifierPurchased:)])
    {
        [self.delegate astStoreControllerProductIdentifierPurchased:productIdentifier];
    }
}

- (void)invokeDelegateStoreControllerProductIdentifierExpired:(NSString*)productIdentifier
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerProductIdentifierExpired:)])
    {
        [self.delegate astStoreControllerProductIdentifierExpired:productIdentifier];
    }
}

- (void)invokeDelegateStoreControllerProductIdentifierCancelledPurchase:(NSString*)productIdentifier
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerProductIdentifierCancelledPurchase:)])
    {
        [self.delegate astStoreControllerProductIdentifierCancelledPurchase:productIdentifier];
    }
}


- (void)invokeDelegateStoreControllerProductIdentifierFailedPurchase:(NSString*)productIdentifier withError:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerProductIdentifierFailedPurchase:withError:)])
    {
        [self.delegate astStoreControllerProductIdentifierFailedPurchase:productIdentifier withError:error];
    }
}

- (void)invokeDelegateStoreControllerRestoreComplete
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(astStoreControllerRestoreComplete)])
    {
        [self.delegate astStoreControllerRestoreComplete];
    }
}

- (void)invokeDelegateStoreControllerRestoreFailedWithError:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector: @selector(astStoreControllerRestoreFailedWithError:)])
    {
        [self.delegate astStoreControllerRestoreFailedWithError:error];
    }
}

#pragma mark Accessors
- (SKPaymentQueue*)skPaymentQueue
{
    return ( [SKPaymentQueue defaultQueue] );
}

- (NSMutableDictionary*)storeProductDictionary
{
    if( nil != storeProductDictionary_ )
    {
        return ( storeProductDictionary_ );
    }
    
    storeProductDictionary_ = [[NSMutableDictionary alloc] init];
    
    return ( storeProductDictionary_ );
}

- (void)setProductDataState:(ASTStoreControllerProductDataState)aProductDataState
{
    if( aProductDataState != productDataState_ )
    {
        @synchronized(self)
        {
            productDataState_ = aProductDataState;
        }

        [self invokeDelegateStoreControllerProductDataStateChanged:aProductDataState];
    }
}

- (ASTStoreControllerProductDataState)productDataState
{
    ASTStoreControllerProductDataState state;
    
    @synchronized(self)
    {
        state = productDataState_;
    }
    
    return state;
    
}
- (void)setPurchaseState:(ASTStoreControllerPurchaseState)aPurchaseState
{
    if( aPurchaseState != purchaseState_ )
    {
        @synchronized(self) 
        {   
            purchaseState_ = aPurchaseState;
        }
        
        [self invokeDelegateStoreControllerPurchaseStateChanged:aPurchaseState];
    }
}

- (ASTStoreControllerPurchaseState)purchaseState
{
    ASTStoreControllerPurchaseState state;
    
    @synchronized(self)
    {
        state = purchaseState_;
    }
    
    return state;
}

- (ASTStoreServer*)storeServer
{
    if( nil != storeServer_ )
    {
        return ( storeServer_ );
    }
    
    storeServer_ = [[ASTStoreServer alloc] init];
    
    return storeServer_;
}

// Only want to instantiate a storeServer if one of the values is changed
// Otherwise there is no point in creating the object; just return default values
// In the case that the storeServer has not otherwise been created
- (NSString*)vendorUuid
{
    if( nil == storeServer_ )
    {
        return nil;
    }
    
    return ( self.storeServer.vendorUuid );
}

- (void)setVendorUuid:(NSString *)vendorUuid
{
    self.storeServer.vendorUuid = vendorUuid;
}

- (NSURL*)serverUrl
{
    if( nil == storeServer_ )
    {
        return nil;
    }
    
    return ( self.storeServer.serverUrl );
}

- (NSTimeInterval)serverConnectionTimeout
{
    if( nil == storeServer_ )
    {
        return ( kASTStoreServerDefaultNetworkTimeout );
    }
    
    return ( self.storeServer.serverConnectionTimeout );
}

- (void)setServerUrl:(NSURL *)serverUrl
{
    self.storeServer.serverUrl = serverUrl;
}

- (void)setServerConnectionTimeout:(NSTimeInterval)serverConnectionTimeout
{
    self.storeServer.serverConnectionTimeout = serverConnectionTimeout;
}

- (void)setServiceURLPaths:(NSDictionary *)serviceURLPaths
{
    self.storeServer.serviceURLPaths = serviceURLPaths;
}

- (NSDictionary*)serviceURLPaths
{
    return self.storeServer.serviceURLPaths;
}

- (void)setSharedSecret:(NSString *)sharedSecret
{
    
    
    self.storeServer.sharedSecret = sharedSecret;
}

- (NSString*)sharedSecret
{
    return self.storeServer.sharedSecret;
}

#pragma mark Product Setup

- (void)setProductIdentifierFromStoreProduct:(ASTStoreProduct*)storeProduct
{
    
    ASTStoreProduct *existingProduct = [self.storeProductDictionary objectForKey:storeProduct.productIdentifier];
    
    if( existingProduct )
    {
        [existingProduct updateProductFromProduct:storeProduct];
    }
    else
    {
        [self.storeProductDictionary setObject:storeProduct forKey:storeProduct.productIdentifier];
        self.productDataState = ASTStoreControllerProductDataStateStale;
    }

}

- (BOOL)setProductIdentifiersFromPath:(NSString*)plistPath
{
    NSArray *productsArray = [ASTStoreProductPlistReader readStoreProductPlistFromFile:plistPath];
    
    if( nil == productsArray )
    {
        DLog(@"Failed to read product information from plist file: %@", plistPath);
        return ( NO );
    }
    
    for( ASTStoreProduct *aProduct in productsArray )
    {
        [self setProductIdentifierFromStoreProduct:aProduct];
    }
    
    return ( YES );
}

- (BOOL)setProductIdentifiersFromBundlePlist:(NSString*)plistName
{
    NSBundle *mainBundle = [NSBundle mainBundle];
                        
    NSString *plistPath = [mainBundle pathForResource:plistName ofType:@"plist"];
    
    if( nil == plistPath )
    {
        DLog(@"Failed to find resource:%@ ofType:plist", plistName);
        return ( NO );
    }
    
    BOOL result = [self setProductIdentifiersFromPath:plistPath];
    
    return ( result );
}


- (BOOL)setNonConsumableProductIdentifier:(NSString*)productIdentifier
{
    ASTStoreProduct *aProduct = [ASTStoreProduct nonConsumableStoreProductWithIdentifier:productIdentifier];
    
    if( nil == aProduct )
    {
        DLog(@"Failed to create product for id:%@", productIdentifier);
        return ( NO );
    }
    
    [self setProductIdentifierFromStoreProduct:aProduct];
    
    return ( YES );
}

- (BOOL)setConsumableProductIdentifier:(NSString*)productIdentifier 
                      familyIdentifier:(NSString*)familyIdentifier 
                        familyQuantity:(NSUInteger)familyQuantity
{
    ASTStoreProduct *aProduct = [ASTStoreProduct consumableStoreProductWithIdentifier:productIdentifier 
                                                                     familyIdentifier:familyIdentifier 
                                                                       familyQuantity:familyQuantity];
    if( nil == aProduct )
    {
        DLog(@"Failed to create product for id:%@", productIdentifier);
        return ( NO );
    }
    
    [self setProductIdentifierFromStoreProduct:aProduct];
    
    return ( YES );

}

- (BOOL)setAutoRenewableProductIdentifier:(NSString*)productIdentifier 
                         familyIdentifier:(NSString*)familyIdentifier 
                           familyQuantity:(ASTStoreProductAutoRenewableType)familyQuantity
{
    ASTStoreProduct *aProduct = [ASTStoreProduct autoRenewableStoreProductWithIdentifier:productIdentifier 
                                                                        familyIdentifier:familyIdentifier 
                                                                          familyQuantity:familyQuantity];
    
    if( nil == aProduct )
    {
        DLog(@"Failed to create product for id:%@", productIdentifier);
        return ( NO );
    }
    
    [self setProductIdentifierFromStoreProduct:aProduct];
    
    return ( YES );
}


- (void)removeProductIdentifier:(NSString*)productIdentifier
{
    [self.storeProductDictionary removeObjectForKey:productIdentifier];
}

- (void)resetProductIdentifier:(NSString*)productIdentifier
{    
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];
    [aProduct.productData removeData];
    
    // Invoke a noop state change to kick any view controllers to refresh data
    [self invokeDelegateStoreControllerProductDataStateChanged:self.productDataState];
}

- (void)resetAllProducts
{
    for( NSString *productIdentifier in [self productIdentifiers] )
    {
        [self resetProductIdentifier:productIdentifier];
    }
}

#pragma mark Query lists of products being managed

- (NSArray*)productIdentifiers
{
    return ( [self.storeProductDictionary allKeys] );
}

- (NSArray*)sortedProductIdentifiers
{
    NSMutableArray *sortedArray = [[[NSMutableArray alloc] 
                                    initWithCapacity:[self.storeProductDictionary count]] 
                                   autorelease];
    
    [sortedArray addObjectsFromArray:[self productIdentifiersForProductType:ASTStoreProductIdentifierTypeNonconsumable 
                                                      sortedUsingComparator:nil]];
    
    [sortedArray addObjectsFromArray:[self productIdentifiersForProductType:ASTStoreProductIdentifierTypeConsumable 
                                                      sortedUsingComparator:nil]];

    [sortedArray addObjectsFromArray:[self productIdentifiersForProductType:ASTStoreProductIdentifierTypeAutoRenewable 
                                                      sortedUsingComparator:nil]];

    return [NSArray arrayWithArray:sortedArray];
}

- (NSComparator)localizedTitleComparator
{
    NSComparator cmptr = ^NSComparisonResult(id obj1, id obj2) 
    {
        ASTStoreProduct *p1 = obj1;
        ASTStoreProduct *p2 = obj2;
        
        NSComparisonResult compResult = [p1.localizedTitle localizedCompare:p2.localizedTitle];
        
        return compResult;
    };

    return [cmptr copy];
}

- (NSComparator)familyQuantityComparator
{
    NSComparator cmptr = ^NSComparisonResult(id obj1, id obj2) 
    {
        ASTStoreProduct *p1 = obj1;
        ASTStoreProduct *p2 = obj2;
        
        if( p1.familyQuanity < p2.familyQuanity )
        {
            return NSOrderedAscending;
        }
        else if ( p1.familyQuanity > p2.familyQuanity )
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    };
    
    return [cmptr copy];
}

- (NSComparator)stringComparator
{
    NSComparator cmptr = ^NSComparisonResult(id obj1, id obj2) 
    {
        NSString *p1 = obj1;
        NSString *p2 = obj2;
        
        NSComparisonResult compResult = [p1 compare:p2];
        
        return compResult;
    };
    
    return [cmptr copy];
}

- (NSArray*)productIdentifiersForProductType:(ASTStoreProductIdentifierType)type sortedUsingComparator:(NSComparator)cmptr
{
    NSMutableArray *unsortedArray = [[[NSMutableArray alloc] init] autorelease];
    
    for( NSString *aProductId in self.storeProductDictionary )
    {
        ASTStoreProduct *aProduct = [self.storeProductDictionary objectForKey:aProductId];
        
        if( aProduct.type == type )
        {
            [unsortedArray addObject:aProduct];
        }
    }
    
    if( nil == cmptr )
    {
        // if no comparator supplied, sort alphabetically by localizedTitle
        cmptr = [self localizedTitleComparator];
    }
    
    NSArray *titleSortedArray = [unsortedArray sortedArrayUsingComparator:cmptr];
    
    // Create the final array by creating an array of product identifiers
    NSMutableArray *sortedProductIdArray = [[[NSMutableArray alloc] initWithCapacity:[titleSortedArray count]] autorelease];
    for( ASTStoreProduct *aProduct in titleSortedArray )
    {
        [sortedProductIdArray addObject:aProduct.productIdentifier];
    }
    
    return [NSArray arrayWithArray:sortedProductIdArray];
}


- (ASTStoreProduct*)storeProductForIdentifier:(NSString*)productIdentifier
{
    return ( [self.storeProductDictionary objectForKey:productIdentifier] );
}

- (ASTStoreProductData*)storeProductDataForIdentifier:(NSString*)productIdentifier
{
    // Attempt to get the product object for this - if that fails
    // Then attempt to the product data object for transaction - 
    ASTStoreProductData *productData = nil;    
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil != theProduct )
    {
        productData = theProduct.productData;
    }
    else
    {
        productData = [ASTStoreProductData storeProductDataFromProductIdentifier:productIdentifier];
    }

    return productData;
}

- (NSArray*)uniqueFamilyIdentifiersForProductType:(ASTStoreProductIdentifierType)type 
                            sortedUsingComparator:(NSComparator)cmptr
{
    NSMutableSet *familyIdSet = [[NSMutableSet alloc] init];

        
    for( NSString *productId in self.storeProductDictionary )
    {
        ASTStoreProduct *theProduct = [self.storeProductDictionary objectForKey:productId];
        
        if( theProduct.type == type )
        {
            [familyIdSet addObject:theProduct.familyIdentifier];
        }
    }
    
    NSArray *result = nil;
    
    if( [familyIdSet count] > 0 )
    {
        if( nil == cmptr )
        {
            cmptr = [self stringComparator];
        }
        
        result = [[familyIdSet allObjects] sortedArrayUsingComparator:cmptr];
    }
    
    [familyIdSet release];
    
    return result;
}

- (NSArray*)storeProductsForFamilyIdentifier:(NSString*)familyIdentifier
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        
    for( NSString *productId in self.storeProductDictionary )
    {
        ASTStoreProduct *theProduct = [self.storeProductDictionary objectForKey:productId];

        if( [theProduct.familyIdentifier isEqualToString:familyIdentifier] )
        {
            [tmpArray addObject:theProduct];
        }
    }
    
    NSArray *result = nil;
    
    if( [tmpArray count] > 0 )
    {
        ASTStoreProduct *aProduct = [tmpArray objectAtIndex:0];
        NSComparator cmptr;
        
        if( aProduct.type == ASTStoreProductIdentifierTypeAutoRenewable )
        {
            cmptr = [self familyQuantityComparator];
        }
        else
        {
            cmptr = [self stringComparator];
        }
        
        result = [tmpArray sortedArrayUsingComparator:cmptr];
    }
    
    [tmpArray release];
    
    return result;
}


#pragma mark SKProductRequest and SKRequest Delegate Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    DLog(@"request:%@ response:%@", request, response);
    
    for( SKProduct *aProduct in response.products )
    {
        // Associate the SKProduct with the appropriate ASTStoreProduct
        DLog(@"Associating valid data for %@ : %@", aProduct.productIdentifier, aProduct);
        ASTStoreProduct *storeProduct = [self.storeProductDictionary objectForKey:aProduct.productIdentifier];
        storeProduct.skProduct = aProduct;
        storeProduct.isValid = YES;
    }
    
    for( NSString *productIdentifier in response.invalidProductIdentifiers )
    {
        DLog(@"Setting invalid productIdentifier: %@", productIdentifier);
        ASTStoreProduct *storeProduct = [self.storeProductDictionary objectForKey:productIdentifier];
        storeProduct.skProduct = nil;
        storeProduct.isValid = NO;
    }
    
    self.skProductsRequest = nil;
    self.productDataState = ASTStoreControllerProductDataStateUpToDate;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    DLog(@"request:%@ error:%@", request, error);
    
    if( [request isKindOfClass:[SKProductsRequest class]] )
    {
        self.skProductsRequest = nil;
        self.productDataState = ASTStoreControllerProductDataStateStale;
        
        // Queue up a retry - if enabled
        if( 0 != self.retryStoreConnectionInterval )
        {
            double delayInSeconds = self.retryStoreConnectionInterval;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
            {
                [self requestProductDataFromiTunes:NO];
            });
        }
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    DLog(@"%@", request);
}

#pragma mark Update Products from iTunes

- (void)requestProductDataFromiTunes:(BOOL)force
{
    BOOL needsRefresh;
    
    switch (self.productDataState) 
    {
        case ASTStoreControllerProductDataStateStale:
        case ASTStoreControllerProductDataStateStaleTimeout:
            needsRefresh = YES;
            break;
            
        case ASTStoreControllerProductDataStateUpToDate:
            needsRefresh = force;
            break;
            
        case ASTStoreControllerProductDataStateUpdating:
        case ASTStoreControllerProductDataStateUnknown: 
        default:
            needsRefresh = NO;
            break;
    }
    
    if( NO == needsRefresh )
    {
        return;
    }
    
    // Create an SKProductsRequest from the ASTStoreProducts
    NSSet *productIdentifierSet = [NSSet setWithArray:[self productIdentifiers]];
    self.skProductsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifierSet] autorelease];
    self.skProductsRequest.delegate = self;
    
    self.productDataState = ASTStoreControllerProductDataStateUpdating;
    
    [self.skProductsRequest start];
}

#pragma mark Transaction Handling
- (void)updatePurchaseFromProductData:(ASTStoreProductData*)productData
{
    switch (productData.type) 
    {
        case ASTStoreProductIdentifierTypeConsumable:
        {
            // Increment the available quantity for the family
            NSUInteger quantity = productData.availableQuantity;
            quantity += productData.familyQuanity;
            
            productData.availableQuantity = quantity;
            break;
        }
            
        case ASTStoreProductIdentifierTypeNonconsumable:
        {
            productData.availableQuantity = 1;
            break;
        }
          
        case ASTStoreProductIdentifierTypeAutoRenewable:
        {
            NSDate *now = [NSDate date];
            NSTimeInterval secondsToAdd = productData.familyQuanity;
            productData.expiresDate = [now dateByAddingTimeInterval:secondsToAdd];
            break;
        }
            
        default:
            DLog(@"Unsupported product type: %d", productData.type);
            break;
    }
}

- (void)updatePurchaseFromProductIdentifier:(NSString*)productIdentifier
{
    ASTStoreProductData *productData = [self storeProductDataForIdentifier:productIdentifier];    
    
    if( nil == productData )
    {
        // Have no information how to process this payment - abort
        ALog(@"Failed to obtain product data for:%@", productIdentifier);
        return;
    }
    
    [self updatePurchaseFromProductData:productData];
}

- (void)completionHandlerForProductData:(ASTStoreProductData*)productData 
                            transaction:(SKPaymentTransaction *)transaction 
                 withVerificationResult:(ASTStoreServerResult)result
{   
    if(( ASTStoreServerResultPass == result ) || ( ASTStoreServerResultInconclusive == result ))
    {
        [self updatePurchaseFromProductData:productData];
        [self invokeDelegateStoreControllerProductIdentifierPurchased:productData.productIdentifier];
    }
    else if( ASTStoreServerResultFail == result )
    {
        [self invokeDelegateStoreControllerProductIdentifierFailedPurchase:productData.productIdentifier withError:nil];
    }
    
    if( self.restoringPurchases )
    {
        // If restoring, there may be multiple transactions so set back to processing
        // Will change state back to none as part of the restore complete callback
        self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;
    }
    else
    {
        self.purchaseState = ASTStoreControllerPurchaseStateNone;
    }
    
    // Remove the transaction from the payment queue
    [self.skPaymentQueue finishTransaction:transaction];
}

- (void)invokeSubscriptionProductDelegates:(ASTStoreProductData*)productData previousState:(BOOL)previousPurchaseState
{
    BOOL productIsPurchased = [productData isPurchased];
    
    if(( YES == productIsPurchased)  && ( previousPurchaseState == NO ))
    {
        [self invokeDelegateStoreControllerProductIdentifierPurchased:productData.productIdentifier];
    }
    else if(( NO == productIsPurchased ) && ( previousPurchaseState == YES ))
    {
        [self invokeDelegateStoreControllerProductIdentifierExpired:productData.productIdentifier];
    }
}

- (void)completionHandlerForSubscriptionProductData:(ASTStoreProductData*)productData
                                        expiresDate:(NSDate*)expiresDate
                            latestReceiptBase64Data:(NSString*)latestReceiptBase64Data
                            transaction:(SKPaymentTransaction *)transaction 
                 withVerificationResult:(ASTStoreServerResult)result
{    
    BOOL previousPurchaseState = [productData isPurchased];
        
    if( nil == transaction )
    {
        // Came in from the expiry timer handler, since there is no transaction provided.
        // Thus we can assume that the previous state was purchased, otherwise no timer
        // would have been set. Since chances are the [productData isPurchased] would be
        // NO in this case, must reset it so that any expiry delegates are invoked
        previousPurchaseState = YES;
    }
    
    DLog(@"prevPurchase:%d result:%d", previousPurchaseState, result);
    
    if( ASTStoreServerResultPass == result )
    {
        // Pass could mean subscription is valid or it could be expired - will need to check the date
        productData.expiresDate = expiresDate;
        
        if( nil != latestReceiptBase64Data )
        {
            productData.receipt = latestReceiptBase64Data;            
        }
        else if( transaction != nil )
        {
            productData.receipt = [ASIHTTPRequest base64forData:transaction.transactionReceipt];
        }
        
        [self invokeSubscriptionProductDelegates:productData previousState:previousPurchaseState];
    }
    else if ( ASTStoreServerResultInconclusive == result )
    {
        // Basically a network error
        // Treat this like a promo code by setting the expiry based on now + 
        // length of the subscription
        [self updatePurchaseFromProductData:productData];
        [self invokeSubscriptionProductDelegates:productData previousState:previousPurchaseState];
    }
    else if( ASTStoreServerResultFail == result )
    {
        [self invokeDelegateStoreControllerProductIdentifierFailedPurchase:productData.productIdentifier withError:nil];
    }
    
    if( nil != transaction )
    {
        if( self.restoringPurchases )
        {
            // If restoring, there may be multiple transactions so set back to processing
            // Will change state back to none as part of the restore complete callback
            self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;
        }
        else
        {
            self.purchaseState = ASTStoreControllerPurchaseStateNone;
        }
        
        // Remove the transaction from the payment queue
        [self.skPaymentQueue finishTransaction:transaction];
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction 
{     
    DLog(@"serverURL:%@ verify:%d", self.serverUrl, self.verifyReceipts);
    
    NSString *productIdentifier = [ASTStoreServer productIdentifierForTransaction:transaction];
    ASTStoreProductData *productData = [self storeProductDataForIdentifier:productIdentifier];    

    if( nil == productData )
    {
        // Have no information how to process this payment - abort
        ALog(@"Failed to obtain product data for:%@", productIdentifier);
        return;
    }
    
    // Need to check the product type - if autorenewable then must verify to
    // determine when it expires by grabbing the receipt data from the app store
    
    if( productData.type == ASTStoreProductIdentifierTypeAutoRenewable )
    {
        self.purchaseState = ASTStoreControllerPurchaseStateVerifyingReceipt;
        
        NSString *base64Receipt = [ASIHTTPRequest base64forData:transaction.transactionReceipt];
        
        [self.storeServer asyncVerifySubscriptionReceipt:base64Receipt 
                         withCompletionBlock:^(NSString *receiptBase64Data, 
                                               NSDate *expiresDate, 
                                               NSString *latestReceiptBase64Data, 
                                               ASTStoreServerResult result) 
        {
            [self completionHandlerForSubscriptionProductData:productData 
                                                  expiresDate:expiresDate 
                                      latestReceiptBase64Data:latestReceiptBase64Data 
                                                  transaction:transaction 
                                       withVerificationResult:result];
        }];
    }
    else if(( self.serverUrl != nil ) && ( self.verifyReceipts ))
    {
        self.purchaseState = ASTStoreControllerPurchaseStateVerifyingReceipt;
        
        [self.storeServer asyncVerifyTransaction:transaction 
                             withCompletionBlock:^(SKPaymentTransaction *transaction, 
                                                   ASTStoreServerResult result) 
         {
             [self completionHandlerForProductData:productData transaction:transaction withVerificationResult:result];
         }];
    }
    else
    {
        // No server verification to do - assume pass and invoke handler directly
        [self completionHandlerForProductData:productData transaction:transaction withVerificationResult:ASTStoreServerResultPass];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    self.purchaseState = ASTStoreControllerPurchaseStateNone;

    if (transaction.error.code != SKErrorPaymentCancelled) 
    {
        [self invokeDelegateStoreControllerProductIdentifierFailedPurchase:transaction.payment.productIdentifier
                                                                 withError:transaction.error];
    }
    else
    {
        [self invokeDelegateStoreControllerProductIdentifierCancelledPurchase:transaction.payment.productIdentifier];
    }
    
    [self.skPaymentQueue finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction 
{
    DLog(@"restoring: %@", transaction.payment.productIdentifier);
    
    [self completeTransaction:transaction];
}

#pragma mark ASTStoreFamilyDataProtocol delegate methods
- (void)astFamilyDataVerifySubscriptionForFamilyData:(ASTStoreFamilyData*)familyData
{
    [self.storeServer asyncVerifySubscriptionReceipt:familyData.receipt 
                                 withCompletionBlock:^(NSString *receiptBase64Data, 
                                                       NSDate *expiresDate, 
                                                       NSString *latestReceiptBase64Data, 
                                                       ASTStoreServerResult result) 
     {
         if( result == ASTStoreServerResultUnconfigured )
         {
             DLog(@"Attempted to verify subscription for family:%@ but no server or shared secret found.", familyData);
             return;
         }
         
         // Find any products with the family id and invoke the handler
         NSArray *renewableProductIds = [self storeProductsForFamilyIdentifier:familyData.familyIdentifier];
         
         for( ASTStoreProduct *product in renewableProductIds )
         {
             ASTStoreProductData *productData = [ASTStoreProductData storeProductDataFromProductIdentifier:product.productIdentifier];
             
             [self completionHandlerForSubscriptionProductData:productData
                                                   expiresDate:expiresDate 
                                       latestReceiptBase64Data:latestReceiptBase64Data 
                                                   transaction:nil 
                                        withVerificationResult:result];

         }
     }];

    DLog(@"invoked");
}

#pragma mark SKPaymentTransactionObserver Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) 
    {
        switch (transaction.transactionState) 
        {
            case SKPaymentTransactionStatePurchased: 
                [self completeTransaction:transaction]; 
                break;
                
            case SKPaymentTransactionStateFailed: 
                [self failedTransaction:transaction]; 
                break;
                
            case SKPaymentTransactionStateRestored: 
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    DLog(@"restore complete");
    self.restoringPurchases = NO;
    if( self.purchaseState == ASTStoreControllerPurchaseStateProcessingPayment )
    {
        // Could be verifying in the background - only update to none state if 
        // last known state was processing. Since restoringPurchase flag has been
        // disabled, the finalize transation will deal with resetting state to none.
        self.purchaseState = ASTStoreControllerPurchaseStateNone;
    }
    [self invokeDelegateStoreControllerRestoreComplete];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    DLog(@"failed:%@", error);
    [self invokeDelegateStoreControllerRestoreFailedWithError:error];
    self.purchaseState = ASTStoreControllerPurchaseStateNone;
}

#pragma mark Purchase

- (void)purchaseCompletionHandler:(NSString*)productIdentifier 
               customerIdentifier:(NSString*)customerIdentifier 
        productPromoCodeAvailable:(BOOL)productPromoCodeAvailable
{
    if( NO == productPromoCodeAvailable )
    {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier]; 
        [self.skPaymentQueue addPayment:payment];
    }
    else
    {
        // Promo code accepted - activate product...
        [self updatePurchaseFromProductIdentifier:productIdentifier];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Thank You" 
                                                         message:@"Your promo code was successfully redeemed." 
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];

        [self invokeDelegateStoreControllerProductIdentifierPurchased:productIdentifier];
        self.purchaseState = ASTStoreControllerPurchaseStateNone;
        
    }
}

- (void)purchaseProduct:(NSString*)productIdentifier
{
    if( self.purchaseState != ASTStoreControllerPurchaseStateNone )
    {
        // Not in a terminal purchase state - reject request
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Purchase In Progress" 
                                                         message:@"Another purchase is in progress. Please wait for it to complete and try again." 
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        
        return;
    }
    
    if( ! [SKPaymentQueue canMakePayments] )
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Purchases Disabled" 
                                                         message:@"In App Purchase is Disabled. Please check Settings -> General -> Restrictions." 
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];

        return;
    }
    
    self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;

    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( theProduct.isFree )
    {
        // Treat it like a valid promo code
        [self purchaseCompletionHandler:productIdentifier 
                     customerIdentifier:self.customerIdentifier 
              productPromoCodeAvailable:YES];
    }
    else if( self.serverPromoCodesEnabled )
    {
        [self.storeServer asyncIsProductPromoCodeAvailableForProductIdentifier:productIdentifier 
                                                         andCustomerIdentifier:self.customerIdentifier 
                                                           withCompletionBlock:^(NSString *productIdentifier,
                                                                                 NSString *customerIdentifier,
                                                                                 BOOL result)
         {
             [self purchaseCompletionHandler:productIdentifier 
                          customerIdentifier:customerIdentifier 
                   productPromoCodeAvailable:result];
         }];
    }
    else
    {
        [self purchaseCompletionHandler:productIdentifier 
                     customerIdentifier:self.customerIdentifier 
              productPromoCodeAvailable:NO];
    }
}

- (void)restorePreviousPurchases
{
    if( self.purchaseState != ASTStoreControllerPurchaseStateNone )
    {
        // Not in a terminal purchase state - reject request
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Purchase In Progress" 
                                                         message:@"Another purchase is in progress. Please wait for it to complete and try again." 
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        
        return;
    }
    
    self.restoringPurchases = YES;
    self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;
    [self.skPaymentQueue restoreCompletedTransactions];
}

- (void)setProductPurchased:(NSString*)productIdentifier withQuantity:(NSUInteger)totalQuantityAvailable
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil != theProduct )
    {
        [theProduct setPurchasedQuantity:totalQuantityAvailable];
        return;
    }
    
    // In the event a family id was provided instead of a product id, set directly against family
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:productIdentifier];
    
    if( nil != familyData )
    {
        [familyData setAvailableQuantity:totalQuantityAvailable];
    }
}

- (NSUInteger)produceProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToProduce
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    NSUInteger quantity;
    
    if( nil != theProduct )
    {
        if( theProduct.type != ASTStoreProductIdentifierTypeConsumable )
        {
            return 0;
        }
        
        quantity = theProduct.availableQuantity;
        quantity += amountToProduce;
        
        [theProduct setPurchasedQuantity:quantity];
        return quantity;
    }
    
    // In the event a family id was provided instead of a product id, set directly against family
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:productIdentifier];
    
    if( nil != familyData )
    {
        if( familyData.type != ASTStoreProductIdentifierTypeConsumable )
        {
            return 0;
        }
        
        quantity = familyData.availableQuantity;
        quantity += amountToProduce;
        
        [familyData setAvailableQuantity:quantity];
        
        return quantity;
    }
    
    return 0;
}

#pragma mark Querying Purchases

- (BOOL)isProductPurchased:(NSString*)productIdentifier
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    NSString *familyIdentifier = productIdentifier;
    
    if( nil != theProduct )
    {
        familyIdentifier = theProduct.familyIdentifier;
    }
    
    // In the event a family id was provided instead of a product id, attempt to directly access family id
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:familyIdentifier];
    
    if( nil != familyData )
    {
        BOOL isPurchased = familyData.isPurchased;
        return ( isPurchased );
    }
    
    return NO;
}

- (NSUInteger)availableQuantityForProduct:(NSString*)productIdentifier
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil != theProduct )
    {
        return ( theProduct.availableQuantity );
    }
    
    // In the event a family id was provided instead of a product id, attempt to directly access family id
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:productIdentifier];
    
    if( nil != familyData )
    {
        return( familyData.availableQuantity );
    }
    
    DLog(@"Failed to get product data for:%@", productIdentifier);

    return 0;
}

- (NSDate*)expiryDateForProduct:(NSString*)productIdentifier
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil != theProduct )
    {
        return ( theProduct.expiresDate );
    }
    
    // In the event a family id was provided instead of a product id, attempt to directly access family id
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:productIdentifier];
    
    if( nil != familyData )
    {
        return( familyData.expiresDate );
    }

    return nil;
}


- (NSUInteger)consumeProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToConsume
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
 
    if( nil != theProduct )
    {
        return ( [theProduct consumeQuantity:amountToConsume] );        
    }

    // In the event a family id was provided instead of a product id, attempt to directly access family id
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:productIdentifier];
    
    if( nil != familyData )
    {
        return ( [familyData consumeQuantity:amountToConsume] );
    }

    return 0;
}

#pragma mark Read Configuration 

- (void)readConfiguration
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *plistPath = [mainBundle pathForResource:kASTStoreConfigPlist ofType:@"plist"];

    if( nil == plistPath )
    {
        return;
    }
    
    ASTStoreConfig *config = [ASTStoreConfigPlistReader readStoreConfigFromPlistFile:plistPath];
    
    if( nil == config )
    {
        return;
    }
    
    self.retryStoreConnectionInterval = config.retryStoreConnectionInterval;
    self.serverUrl = config.serverURL;
    self.serverConnectionTimeout = config.serverConnectionTimeout;
    self.vendorUuid = config.vendorUuid;
    self.verifyReceipts = config.verifyReceipts;
    self.serverPromoCodesEnabled = config.serverPromoCodesEnabled;
    self.serverConsumablesEnabled = config.serverConsumablesEnabled;
    self.serviceURLPaths = config.serviceURLPaths;
    self.sharedSecret = config.sharedSecret;
    
    if( nil != config.productPlistFile )
    {
        [self setProductIdentifiersFromBundlePlist:config.productPlistFile];
    }
}

#pragma mark Initialization and Cleanup

+ (id) sharedStoreController
{
    static dispatch_once_t pred;
    static ASTStoreController *aSTStoreController = nil;
    
    dispatch_once(&pred, ^{ aSTStoreController = [[self alloc] init]; });
    return aSTStoreController;
}

- (id)init 
{
    self = [super init];
    
    if( nil == self) 
    {
        return ( nil );
    }

    productDataState_ = ASTStoreControllerProductDataStateUnknown;
    delegate_ = nil;
    purchaseState_ = ASTStoreControllerPurchaseStateNone;
    retryStoreConnectionInterval_ = kASTStoreControllerDefaultRetryStoreConnectionInterval;
    verifyReceipts_ = kASTStoreServerDefaultVerifyReceipts;
    restoringPurchases_ = NO;
    customerIdentifier_ = nil;
    serverConsumablesEnabled_ = NO;
    serverPromoCodesEnabled_ = NO;
    
    [ASTStoreFamilyData setFamilyDataDelegate:self];
    
    [self readConfiguration];
    
    // Register as an observer right away
    [self.skPaymentQueue addTransactionObserver:self];
    
    return self;
}

- (void)dealloc
{
    // See opinions expressed here for why this asserts:
    // http://www.mikeash.com/pyblog/friday-qa-2009-10-02-care-and-feeding-of-singletons.html
    ALog(@"Should not be releasing a singleton!");
    [super dealloc];
}

@end
