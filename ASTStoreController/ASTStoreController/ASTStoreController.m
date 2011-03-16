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

#define kASTStoreControllerDefaultNetworkTimeout 60
#define kASTStoreControllerDefaultretryStoreConnectionInterval 20

@interface ASTStoreController() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (readonly) NSMutableDictionary *storeProductDictionary;
@property (nonatomic) ASTStoreControllerProductDataState productDataState;
@property (retain) SKProductsRequest *skProductsRequest;
@property (readonly) SKPaymentQueue *skPaymentQueue;
@property (nonatomic) ASTStoreControllerPurchaseState purchaseState;

@end


@implementation ASTStoreController

#pragma mark Synthesis
@synthesize storeProductDictionary = storeProductDictionary_;
@synthesize productDataState = productDataState_;
@synthesize delegate = delegate_;
@synthesize skProductsRequest = skProductsRequest_;
@synthesize retryStoreConnectionInterval = retryStoreConnectionInterval_;
@synthesize skPaymentQueue;
@synthesize purchaseState = purchaseState_;

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

- (BOOL)isPurchaseStateTerminal
{
    switch (self.purchaseState) 
    {
        case ASTStoreControllerPurchaseStateNone:
        case ASTStoreControllerPurchaseStateFailed:
        case ASTStoreControllerPurchaseStateCancelled:
        case ASTStoreControllerPurchaseStatePurchased:
            return ( YES );
            break;
            
        default:
            break;
    }
    
    return ( NO );
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
    DLog(@"TODO");
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
- (void)completeTransaction:(SKPaymentTransaction *)transaction 
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
    
    DLog(@"Complete: %@ receipt:%@", productIdentifier, transaction.transactionReceipt);
    
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
        // then leave in the queue and service later? What triggers this? Addition 
        // of new products could check the queue? Hmm.
        DLog(@"Failed to obtain product data for:%@", productIdentifier);
        self.purchaseState = ASTStoreControllerPurchaseStateFailed;
        [self.skPaymentQueue finishTransaction:transaction];
        return;
    }
    
    // TODO: Should check with server somewhere in here for receipt verification if configured
    self.purchaseState = ASTStoreControllerPurchaseStateVerifyingReceipt;

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
        
    [self invokeDelegateStoreControllerProductIdentifierPurchased:productIdentifier];
    self.purchaseState = ASTStoreControllerPurchaseStatePurchased;

    // Remove the transaction from the payment queue: what if things need to be downloaded etc... would 
    // like that to be async relative to this... though restoring could always run that behaviour again
    
    [self.skPaymentQueue finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) 
    {
        [self invokeDelegateStoreControllerProductIdentifierFailedPurchase:transaction.payment.productIdentifier
                                                                 withError:transaction.error];
        self.purchaseState = ASTStoreControllerPurchaseStateFailed;
    }
    else
    {
        [self invokeDelegateStoreControllerProductIdentifierCancelledPurchase:transaction.payment.productIdentifier];
        self.purchaseState = ASTStoreControllerPurchaseStateCancelled;
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

    [self invokeDelegateStoreControllerRestoreComplete];
    self.purchaseState = ASTStoreControllerPurchaseStateNone;
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    DLog(@"removed:%@", transactions);
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    DLog(@"failed:%@", error);
    [self invokeDelegateStoreControllerRestoreFailedWithError:error];
    self.purchaseState = ASTStoreControllerPurchaseStateFailed;
}

#pragma mark Purchase
- (void)purchaseProduct:(NSString*)productIdentifier
{
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
    
    if( NO == [self isPurchaseStateTerminal] )
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
    
    self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;
    
    // TODO : Set Purchase States.... and check to make sure purchase is allowed
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier]; 
    [self.skPaymentQueue addPayment:payment];
}

- (void)restorePreviousPurchases
{
    if( NO == [self isPurchaseStateTerminal] )
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
    
    self.purchaseState = ASTStoreControllerPurchaseStateProcessingPayment;

    [self.skPaymentQueue restoreCompletedTransactions];
}

#pragma mark Querying Purchases

- (BOOL)isProductPurchased:(NSString*)productIdentifier
{
    NSUInteger quantity = [self availableQuantityForProduct:productIdentifier]; 
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];

    if(( quantity > 0 ) && ( aProduct.type != ASTStoreProductIdentifierTypeConsumable ))
    {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)availableQuantityForProduct:(NSString*)productIdentifier
{
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];
    
    if( nil == aProduct )
    {
        DLog(@"Failed to get product data for:%@", productIdentifier);
        return 0;
    }
    
    return ( aProduct.productData.availableQuantity );
}

- (NSUInteger)availableQuantityForFamily:(NSString*)familyIdentifier
{
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:familyIdentifier];
    
    if( nil == familyData )
    {
        DLog(@"Failed to get familyData for:%@", familyIdentifier);
        return 0;
    }
    
    return ( familyData.availableQuantity );
}

- (NSUInteger)consumeProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToConsume
{
    ASTStoreProduct *aProduct = [self storeProductForIdentifier:productIdentifier];

    if( aProduct.productData.type != ASTStoreProductIdentifierTypeConsumable )
    {
        return 0;
    }
    
    return ( [self consumeFamily:aProduct.productData.familyIdentifier quantity:amountToConsume] );
}

- (NSUInteger)consumeFamily:(NSString*)familyIdentifier quantity:(NSUInteger)amountToConsume
{
    ASTStoreFamilyData *familyData = [ASTStoreFamilyData familyDataWithIdentifier:familyIdentifier];
    
    if( nil == familyData )
    {
        DLog(@"Failed to get familyData for:%@", familyIdentifier);
        return 0;
    }

    NSUInteger currentQuantity = familyData.availableQuantity;
    NSUInteger consumeQuantity = amountToConsume;
    
    if( currentQuantity < consumeQuantity )
    {
        consumeQuantity = currentQuantity;
    }
    
    // Update the amount of consumables in the family
    currentQuantity -= consumeQuantity;
    familyData.availableQuantity = currentQuantity;
    
    return consumeQuantity;    
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
    retryStoreConnectionInterval_ = kASTStoreControllerDefaultretryStoreConnectionInterval;
    purchaseState_ = ASTStoreControllerPurchaseStateNone;
    
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
