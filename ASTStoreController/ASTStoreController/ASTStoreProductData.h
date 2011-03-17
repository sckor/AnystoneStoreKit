//
//  ASTStoreProductData.h
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-03-15.
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
#import "ASTStoreProductTypes.h"

@interface ASTStoreProductData : NSObject <NSCoding, NSCopying>
{
    // Values needed to handle transactions if they occur on startup prior
    // to the StoreController being initialized with the products
    NSString *productIdentifier_;
    ASTStoreProductIdentifierType type_;
    NSString *familyIdentifier_;
    NSUInteger familyQuanity_;
}

// Used to get access to the store product data from the filesystem
// if the infrastructure not yet initialized. ie: on startup if there
// are outstanding transactions that need to be handled but the plist
// file hasn't been read, or the StoreController class has not been initialized
// with all of the product data yet, then it will still correctly be able to
// manage the purchase
+ (ASTStoreProductData*)storeProductDataFromProductIdentifier:(NSString*)aProductIdentifier;


+ (BOOL)isStoreProductIdentifierTypeValid:(ASTStoreProductIdentifierType)aType;

+ (id)nonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier;

+ (id)consumableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                          familyIdentifier:(NSString*)aFamilyIdentifier 
                            familyQuantity:(NSUInteger)aFamilyQuantity;

+ (id)autoRenewableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                             familyIdentifier:(NSString*)aFamilyIdentifier 
                               familyQuantity:(ASTStoreProductAutoRenewableType)aFamilyQuantity;

+ (id)storeProductWithProductIdentifier:(NSString*)aProductIdentifier 
                                   type:(ASTStoreProductIdentifierType)aType
                       familyIdentifier:(NSString*)aFamilyIdentifier
                         familyQuantity:(NSUInteger)aFamilyQuantity;

- (id)initNonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier;

- (id)initConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                              familyIdentifier:(NSString*)aFamilyIdentifier 
                                familyQuantity:(NSUInteger)aFamilyQuantity;

- (id)initAutoRenewableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                                 familyIdentifier:(NSString*)aFamilyIdentifier 
                                   familyQuantity:(ASTStoreProductAutoRenewableType)aFamilyQuantity;

- (void)removeData;

@property (readonly,retain) NSString *productIdentifier;
@property (readonly) ASTStoreProductIdentifierType type;

// Used to track consumables/AutoRenewables; Required for Consumable and AutoRenewable types
@property (retain) NSString *familyIdentifier;

// Used to manage increments and decrements of item quantities for consumables and autorenewables
@property  (nonatomic) NSUInteger familyQuanity;

// Use to set and get the number of units available in the family
@property  (nonatomic) NSUInteger availableQuantity;


@end
