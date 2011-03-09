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


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
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

@interface ASTStoreController : NSObject 
{
    ASTStoreControllerProductDataState productDataState_;
    NSTimeInterval networkTimeoutDuration_;
    NSTimeInterval retryStoreConnectionInterval_;
    
    id <ASTStoreControllerDelegate> delegate_;
}

+ (id)sharedStoreController;

#pragma mark Set List of Products To Manage
//
// Methods to set the list of products to manage
//
// Plist format (see sampleProductIdentifiers.plist)
// Key: StoreProducts NSArray
//    NSDictionary
//       Mandatory Key: productIdentifier NSString
//       Mandatory Key: type NSString (@"Consumable", @"Nonconsumable", @"AutoRenewable")
//       Optional Key: title NSString - title to use until app store title can be retrieved
//       Optional Key: description NSString - description to use until store description can be retrieved
//       Optional Key: shouldDisplay boolean
//       Optional Key: minimumVersion NSString
//       Optional Key: extraInformation NSString 

// Read in products to manage from a plist included in the application bundle
// The plist name should not include the .plist extension as it will be 
// added automatically
- (BOOL)setProductIdentifiersFromBundlePlist:(NSString*)plistName;

// Provide the full path to the plist file on the local filesystem; should include the .plist extension
- (BOOL)setProductIdentifiersFromPath:(NSString*)plistPath;

// For quick setup if plist is overkill ie: just have simple identifier(s) to manage
- (void)setProductIdentifier:(NSString*)productIdentifier forType:(ASTStoreProductIdentifierType)type;

// Setup an ASTStoreProduct manually and add it to the list
- (void)setProductIdentifierFromStoreProduct:(ASTStoreProduct*)storeProduct;

// Remove an existing product from the list
- (void)removeProductIdentifier:(NSString*)productIdentifier;
- (void)removeStoreProduct:(ASTStoreProduct*)storeProduct;

#pragma mark Query lists of products being managed

// Returns an array of the product identifiers which are being managed
- (NSArray*)productIdentifiers;

// Provides access to the ASTStoreProduct associated with a managed productIdentifier
- (ASTStoreProduct*)storeProductForIdentifier:(NSString*)productIdentifier;

#pragma mark Update Products from iTunes

// Requests product data from iTunes (if needed, or if force=YES)
- (void)requestProductDataFromiTunes:(BOOL)force;

// Determine current state of the product data
@property (nonatomic,readonly) ASTStoreControllerProductDataState productDataState;

#pragma mark Purchase
- (void)purchase:(NSString*)productIdentifier;
- (void)purchaseStoreProduct:(ASTStoreProduct*)storeProduct;
- (void)restorePreviousPurchases;

#pragma mark Delegate
@property (assign) id <ASTStoreControllerDelegate> delegate;

#pragma mark Timeout for network functions
@property  NSTimeInterval networkTimeoutDuration;
@property  NSTimeInterval retryStoreConnectionInterval;

@end


@protocol ASTStoreControllerDelegate <NSObject>
@optional
- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state;
- (void)astStoreControllerProductPurchased:(ASTStoreProduct*)storeProduct;
- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier;
@end



