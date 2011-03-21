//
//  ASTStoreController.h
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ASTStoreProduct.h"


@protocol ASTStoreControllerDelegate;


typedef enum
{
    ASTStoreControllerProductDataStateUnknown,
    ASTStoreControllerProductDataStateStale,
    ASTStoreControllerProductDataStateUpdating,
    ASTStoreControllerProductDataStateStaleTimeout,
    ASTStoreControllerProductDataStateUpToDate
} ASTStoreControllerProductDataState;

typedef enum
{
    ASTStoreControllerPurchaseStateNone,
    ASTStoreControllerPurchaseStateProcessingPayment,
    ASTStoreControllerPurchaseStateVerifyingReceipt,
    ASTStoreControllerPurchaseStateDownloadingContent
} ASTStoreControllerPurchaseState;

@interface ASTStoreController : NSObject 
{
    ASTStoreControllerProductDataState productDataState_;
    ASTStoreControllerPurchaseState purchaseState_;
    BOOL verifyReceipts_;

    id <ASTStoreControllerDelegate> delegate_;
}

+ (id)sharedStoreController;

#pragma mark Set List of Products To Manage
//
// Methods to set the list of products to manage
//
// Plist format (see sampleProductIdentifiers.plist)
// NSArray of
//    NSDictionary
//       Mandatory Key: productIdentifier NSString
//       Mandatory Key: type NSString (@"Consumable", @"Nonconsumable", @"AutoRenewable")
//       Mandatory Key for Consumable and AutoRenewable: 
//          familyIdentifier NSString: used to track consumables/AutoRenewables that should be
//              linked together, but differ based on quanity added when purchased
//              eg: one productIdentifier might purchase 10 berries, another 30 berries
//                  but they should increment and decrement the same berry family resource
//
//       Mandatory Key for Consumable and AutoRenewable: 
//          familyQuantity NSString:
//                     Mandatory For Consumable - should be an NSUInteger formatted as a string; must be > 0
//                     Mandatory For AutoRenewable - should be one of:
//                          @"7Days",
//                          @"1Month",
//                          @"2Months",
//                          @"3Months",
//                          @"6Months",
//                          @"1Year"
//
//       Optional Key: title NSString - title to use until app store title can be retrieved
//       Optional Key: description NSString - description to use until store description can be retrieved
//       Optional Key: shouldDisplay boolean
//       Optional Key: minimumVersion NSString
//       Optional Key: extraInformation NSString 

// Read in products to manage from a plist included in the application bundle
// The plist name should not include the .plist extension as it will be 
// appended automatically
- (BOOL)setProductIdentifiersFromBundlePlist:(NSString*)plistName;

// Provide the full path to the plist file on the local filesystem; should include the .plist extension
- (BOOL)setProductIdentifiersFromPath:(NSString*)plistPath;

// For quick setup if plist is overkill ie: just have simple identifier(s) to manage
- (BOOL)setNonConsumableProductIdentifier:(NSString*)productIdentifier;

- (BOOL)setConsumableProductIdentifier:(NSString*)productIdentifier 
                  familyIdentifier:(NSString*)familyIdentifier 
                    familyQuantity:(NSUInteger)familyQuantity;

- (BOOL)setAutoRenewableProductIdentifier:(NSString*)productIdentifier 
                  familyIdentifier:(NSString*)familyIdentifier 
                    familyQuantity:(ASTStoreProductAutoRenewableType)familyQuantity;


// Remove an existing product from the in memory list, but leaves
// any persistent data on disk alone
- (void)removeProductIdentifier:(NSString*)productIdentifier;

// Removes any persistent data on disk related to the product identifier
// including any data related to the family (ie: all berries associated
// with the family associated with the product will be removed too).
- (void)resetProductIdentifier:(NSString*)productIdentifier;
- (void)resetAllProducts;

#pragma mark Query lists of products being managed

// Returns an array of the product identifiers which are being managed
- (NSArray*)productIdentifiers;

// Provides access to the ASTStoreProduct associated with a managed productIdentifier
- (ASTStoreProduct*)storeProductForIdentifier:(NSString*)productIdentifier;

#pragma mark Update Products from iTunes
// Default to retying store connection every 15 seconds
@property  NSTimeInterval retryStoreConnectionInterval;

// Requests product data from iTunes (if needed, or if force=YES)
- (void)requestProductDataFromiTunes:(BOOL)force;

// Determine current state of the product data
@property (nonatomic,readonly) ASTStoreControllerProductDataState productDataState;

// Determine the current purchase state - only 1 purchase can occur at a time
@property (nonatomic,readonly) ASTStoreControllerPurchaseState purchaseState;

#pragma mark Purchase
- (void)purchaseProduct:(NSString*)productIdentifier;
- (void)restorePreviousPurchases;

#pragma mark Querying Purchases

// Nonconsumable - YES means purchased, NO means not
// Consumable - Always returns NO, since it can be purchased again; check quantity
- (BOOL)isProductPurchased:(NSString*)productIdentifier;

// Nonconsumable - Should always report 1 if purchased, 0 if not
// Consumable - Number of items available in the family associated with the product id
- (NSUInteger)availableQuantityForProduct:(NSString*)productIdentifier;

// Consumable - returns number of items consumed; if amountToConsume is > available then
//              it will consume up to the amount available and return the amount actually consumed
// Nonconsumable - does nothing, returns 0
- (NSUInteger)consumeProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToConsume;

#pragma mark Server Related
// These are used if you want to enable access to Google App Engine support
// for receipt verification - server url should be set to 
// http://xxx.appspot.com
// alternatively can use a local server URL for testing with the
// local appengine instance
@property (retain) NSURL *serverUrl;

// Enable receipt verification with the server - defaults to YES
// But the option is only relevant if server URL is defined above
@property  BOOL verifyReceipts;

// Used to change the timeout waiting for responses from the
// server - defaults to 15 seconds
@property NSTimeInterval serverConnectionTimeout;

#pragma mark Delegate
@property (assign) id <ASTStoreControllerDelegate> delegate;


@end


@protocol ASTStoreControllerDelegate <NSObject>
@optional

#pragma mark Store State Delegate Methods

- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state;

#pragma mark Purchase and Restore Related Delegate Methods

- (void)astStoreControllerPurchaseStateChanged:(ASTStoreControllerPurchaseState)state;

// Should implement this, otherwise no purchase notifications for you
// Restore will invoke astStoreControllerProductIdentifierPurchased: for any restored purchases
- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier;

#pragma mark Purchase Related Delegate Methods
// Invoked for actual purchase failures - may want to display a message to the user
- (void)astStoreControllerProductIdentifierFailedPurchase:(NSString*)productIdentifier withError:(NSError*)error;

// Invoked for cancellations - no message should be shown to user per programming guide
- (void)astStoreControllerProductIdentifierCancelledPurchase:(NSString*)productIdentifier;

#pragma mark Restore Transaction Delegate Methods

// Additionally will invoke this once the restore queue has been processed
- (void)astStoreControllerRestoreComplete;

// Failures during the restore
- (void)astStoreControllerRestoreFailedWithError:(NSError*)error;

@end



