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
    ASTStoreControllerPurchaseStateDownloadingContent,
} ASTStoreControllerPurchaseState;

@interface ASTStoreController : NSObject {}

// Invoke to instantiate or obtain access to the ASTStoreKit controller
// If you have provided an ASTStoreKitConfig.plist file it will automatically read
// and will configure your instance based on the settings provided in the ASTStoreKitConfig.
//
// The following items can be customized. If they keys or plist file is not present then default values
// will used.
// PList Format
// NSDictionary
//     productPlistFile : String - provides the name of a plist file containing a list of the products to manage (see below). 
//              Must have the .plist file extension removed as it will be appended automatically
//              default : nil -  no file will be read and no products will be added
//
//     sharedSecret : String - the shared secret as specified by Apple for use in validation of auto-renewable subscriptions
//              default : nil
//              HIGHLY RECOMMEND USING A SERVER RATHER THAN INCLUDING THE SHARED SECRET IN APP
//
//     retryStoreConnectionInterval : Number - the amount of seconds to retry access to the iTunes store if unavailable
//              default : 15 seconds
//
//     serverURL : String - URL for the StoreServer. Typically would be an app engine URL eg: "http://xxx.appspot.com"
//              default : nil - no server will be configured
//
//     serverConnectionTimeout : Number - the amount of seconds to wait for server to respond before failing
//              default : 15 seconds
//
//     vendorUuid : String - A UUID provided by the server for validating your access to the server functionality
//              default : nil - no UUID will be set
//
//     verifyReceipts : Boolean - Enables using the server to validate iTunes receipts for authenticity
//              default: NO
//
//     serverPromoCodesEnabled : Boolean - Enables checks with the server to see whether a particular purchase
//              should be granted for free based on the device being registered as a promo enabled device
//              default : NO
//
//     serverConsumablesEnabled : Boolean - Enables storage of consumable counts on the server (useful for potentially
//              transferring and maintaining consumable counts across devices)
//              default : NO
//
//     serviceURLPaths : NSDictionary of keys which allow configuration of the paths to use for accessing server functionality
//              receiptValidation : String - path to send receipt validation service requests
//                        default : service/receipt/validate
//
//              promoCodeValidation : String - path to send requests to validate that device has been enabled for promo code
//                        default : service/purchase/validate
//
//              productQuery : String - path to send product query requests
//                        default : service/product/query
//
//              productList : String - path to send product list requests
//                        default : service/product/list

+ (id)sharedStoreController;

+ (NSString*)version;

#pragma mark Set List of Products To Manage
//
// Methods to set the list of products to manage
//
// Plist format (see sampleProductIdentifiers.plist)
// NSArray of
//    NSDictionary
//       Mandatory Key: productIdentifier NSString
//       Mandatory Key: productType NSString (@"Consumable", @"Nonconsumable", @"AutoRenewable")
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
//       Optional Key: isHidden boolean
//       Optional Key: minimumVersion NSString
//       Optional Key: extraInformation NSString 
//       Optional Key: isFree boolean - should allow purchase without going to app store
//       Optional Key: productImage - Image file name to use when displaying item. 
//                                    Should be 57x57 and 114x114 @2x for Retina display


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

// Configures the shared secret required for validating auto renewable subscriptions
// HIGHLY RECOMMEND USING A SERVER RATHER THAN INCLUDING THE SHARED SECRET IN APP
@property (copy) NSString *sharedSecret;

#pragma mark Query lists of products being managed

// Returns an array of the all of product identifiers which are being managed
- (NSArray*)productIdentifiers;

// Returns an array of all of the product identifiers which are being managed
// sorted by consumable, nonconsumable and autorenewable with each
// section sorted alphabetically by localized title
- (NSArray*)sortedProductIdentifiers;

// Returns a sorted array of the product identifiers for a specific type of product
// If cmptr is nil, then it will sort alphabetically by localized title
// comparator objects are of type ASTStoreProduct
- (NSArray*)productIdentifiersForProductType:(ASTStoreProductIdentifierType)type 
                       sortedUsingComparator:(NSComparator)cmptr;


// Provides access to the ASTStoreProduct associated with a managed productIdentifier
- (ASTStoreProduct*)storeProductForIdentifier:(NSString*)productIdentifier;

// Returns an array of NSString family identifiers for a type of product where
// the family identifier will only appear once (ie: unique family identifier)
- (NSArray*)uniqueFamilyIdentifiersForProductType:(ASTStoreProductIdentifierType)type 
                                                   sortedUsingComparator:(NSComparator)cmptr;

// Returns an array of store products for the correstponding familyIdentifier
// Typically useful for auto renewables and maybe for consumables
// For autoRenewables sorted by subscription duration
// Fpr others - sorted alphabetically by name
- (NSArray*)storeProductsForFamilyIdentifier:(NSString*)familyIdentifier;

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

#pragma mark Producing Products
// Consumable - increments the number of available units by amountToConsume; returns
//              total number of products available
// Nonconsumable - does nothing, returns 0 (use setProductPurchased for Nonconsumables)
- (NSUInteger)produceProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToProduce;

// If you need to force the local purchase state (perhaps migrating from another in-app purchase system)
// This function will allow for setting the purchase quanity without going through the app store
// directly; quantity is only used if type is consumable
- (void)setProductPurchased:(NSString*)productIdentifier withQuantity:(NSUInteger)totalQuantityAvailable;

#pragma mark Querying Purchases

// Nonconsumable - YES means purchased, NO means not
// Consumable - Always returns NO, since it can be purchased again; check quantity
// AutoRenewable - YES means active subscription, NO means subscription expired
- (BOOL)isProductPurchased:(NSString*)productIdentifier;

// Nonconsumable - Should always report 1 if purchased, 0 if not
// Consumable - Number of items available in the family associated with the product id
// AutoRenewable - Does not apply - will return 0
- (NSUInteger)availableQuantityForProduct:(NSString*)productIdentifier;

// Nonconsumable - N/A - returns nil
// Consumable - N/A - returns nil
// AutoRenewable - Returns expiry date (may be expired) or nil (which means sub not active or has expired)
- (NSDate*)expiryDateForProduct:(NSString*)productIdentifier;

#pragma mark Consuming Purchases
// Consumable - returns number of items consumed; if amountToConsume is > available then
//              it will consume up to the amount available and return the amount actually consumed
// Nonconsumable - does nothing, returns 0
// AutoRenewable - does nothing, returns 0
- (NSUInteger)consumeProduct:(NSString*)productIdentifier quantity:(NSUInteger)amountToConsume;



#pragma mark Server Related
// These are used if you want to enable access to Google App Engine support
// for receipt verification - server url should be set to 
// http://xxx.appspot.com
// alternatively can use a local server URL for testing with the
// local appengine instance
@property (copy) NSURL *serverUrl;

// For certain requests a unique vendor uuid is required for accessing
// the services. This will be generated by the server and should be set
// prior to accessing the service
@property (copy) NSString *vendorUuid;

// Used to change the timeout waiting for responses from the
// server - defaults to 15 seconds
@property NSTimeInterval serverConnectionTimeout;

// Enable receipt verification with the server - defaults to YES
// But the option is only relevant if server URL is defined above
@property  BOOL verifyReceipts;

// Use this string to uniquely identify a customer on the server; This ID
// should ideally span devices (for instance a GameCenter player identifier).
// If this is not set, then the system will only make use of the UDID
// which will mean that consumables and promo codes cannot span across multiple devices
@property (copy) NSString *customerIdentifier;

// Dictionary of paths to use for the various services provided by the server
// See sharedStoreController docs above for the keys to set
@property (copy) NSDictionary *serviceURLPaths;

#pragma mark Server Promo Code Support

// If enabled, will check the server to see if the UDID or customerIdentifier
// has been given permission to "purchase" the product for free
@property BOOL serverPromoCodesEnabled;

#pragma mark Server Consumable Support


// Select whether or not to use server management of consumables
// Defaults to NO. When changed from NO to YES, will query current
// count from server
@property BOOL serverConsumablesEnabled;


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

// Should implement this if you are using auto-renewable subscriptions.
// This method will be invoked upon expiry of the subscription
- (void)astStoreControllerProductIdentifierExpired:(NSString*)productIdentifier;

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



