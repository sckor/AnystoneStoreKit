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

#define kASTStoreControllerDefaultRetryStoreConnectionInterval 15.0
#define kASTStoreServerDefaultVerifyReceipts YES

@interface ASTStoreController() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

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

- (ASTStoreProduct*)storeProductForIdentifier:(NSString*)productIdentifier
{
    return ( [self.storeProductDictionary objectForKey:productIdentifier] );
}

#pragma mark SKProductRequest and SKRequest Delegate Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    DLog(@"request:%@ response:%@", request, response);
    
    for( SKProduct *aProduct in response.products )
    {
        // Associate the SKProduct with the appropriate ASTStoreProduct
        DLog(@"Associating valid data for %@", aProduct.productIdentifier);
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
- (void)updatePurchaseFromProductIdentifier:(NSString*)productIdentifier
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
    
    if( nil == productData )
    {
        // Have no information how to process this payment - abort
        ALog(@"Failed to obtain product data for:%@", productIdentifier);
        return;
    }
    
    if( productData.type == ASTStoreProductIdentifierTypeConsumable )
    {
        // Increment the available quantity for the family
        NSUInteger quantity = productData.availableQuantity;
        quantity += productData.familyQuanity;
        
        productData.availableQuantity = quantity;
    }
    else if ( productData.type == ASTStoreProductIdentifierTypeNonconsumable )
    {
        productData.availableQuantity = 1;
    }
    else
    {
        DLog(@"Unsupported product type: %d", productData.type);
    }

}

- (void)completionHandler:(SKPaymentTransaction *)transaction withVerificationResult:(ASTStoreServerResult)result
{
    NSString *productIdentifier = [ASTStoreServer productIdentifierForTransaction:transaction];
    
    if( ASTStoreServerResultFail == result )
    {
        // receipt verification failed
        self.purchaseState = ASTStoreControllerPurchaseStateNone;
        
        [self invokeDelegateStoreControllerProductIdentifierFailedPurchase:productIdentifier withError:nil];
        [self.skPaymentQueue finishTransaction:transaction];
        return;
    }
    else if( ASTStoreServerResultInconclusive == result )
    {
        // TODO: Should keep it around and try verifying it later as an audit type function
    }

    
    [self updatePurchaseFromProductIdentifier:productIdentifier];
            
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
    
    [self invokeDelegateStoreControllerProductIdentifierPurchased:productIdentifier];
    
    // Remove the transaction from the payment queue
    [self.skPaymentQueue finishTransaction:transaction];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction 
{     
    DLog(@"serverURL:%@ verify:%d", self.serverUrl, self.verifyReceipts);

    if(( self.serverUrl != nil ) && ( self.verifyReceipts ))
    {
        self.purchaseState = ASTStoreControllerPurchaseStateVerifyingReceipt;
        
        [self.storeServer asyncVerifyTransaction:transaction 
                             withCompletionBlock:^(SKPaymentTransaction *transaction, 
                                                   ASTStoreServerResult result) 
         {
             [self completionHandler:transaction withVerificationResult:result];
         }];
    }
    else
    {
        // No server verification to do - assume pass and invoke handler directly
        [self completionHandler:transaction withVerificationResult:ASTStoreServerResultPass];
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
    self.purchaseState = ASTStoreControllerPurchaseStateNone;
    [self invokeDelegateStoreControllerRestoreFailedWithError:error];
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
    [theProduct setPurchasedQuantity:totalQuantityAvailable];
}

#pragma mark Querying Purchases

- (BOOL)isProductPurchased:(NSString*)productIdentifier
{
    ASTStoreProduct *theProduct = [self storeProductForIdentifier:productIdentifier];
    return ( theProduct.isPurchased );
}

- (NSUInteger)availableQuantityForProduct:(NSString*)productIdentifier
{
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil == aProduct )
    {
        DLog(@"Failed to get product data for:%@", productIdentifier);
        return 0;
    }
    
    return ( aProduct.availableQuantity );
}

- (NSUInteger)consumeProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToConsume
{
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];

    return ( [aProduct consumeQuantity:amountToConsume] );
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
