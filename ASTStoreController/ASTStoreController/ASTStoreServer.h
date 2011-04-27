//
//  ASTStoreServer.h
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

#import <Foundation/Foundation.h>
#import "ASTStoreKit.h"
#import "ASTStoreProduct.h"

typedef enum
{
    ASTStoreServerResultPass,
    ASTStoreServerResultFail,
    ASTStoreServerResultInconclusive
} ASTStoreServerResult;

#define kASTStoreServerDefaultNetworkTimeout 15.0

@interface ASTStoreServer : NSObject {}

+ (NSString*)productIdentifierForTransaction:(SKPaymentTransaction*)transaction;

@property (copy) NSURL *serverUrl;
@property (copy) NSString *vendorUuid;
@property  NSTimeInterval serverConnectionTimeout;

#pragma mark Verify Related Methods
- (ASTStoreServerResult)verifyTransaction:(SKPaymentTransaction*)transaction; 


typedef void (^ASTVerifyReceiptBlock)(SKPaymentTransaction* transaction,
                                      ASTStoreServerResult result);

- (void)asyncVerifyTransaction:(SKPaymentTransaction*)transaction
           withCompletionBlock:(ASTVerifyReceiptBlock)completionBlock;

#pragma mark In App Promo Related Methods

- (BOOL)isProductPromoCodeAvailableForProductIdentifier:(NSString*)productIdentifier 
                                  andCustomerIdentifier:(NSString*)customerIdentifier;


typedef void (^ASTProductPromoCodeBlock)(NSString *productIdentifier,
                                         NSString *customerIdentifier,
                                         BOOL result);

- (void)asyncIsProductPromoCodeAvailableForProductIdentifier:(NSString*)productIdentifier 
                                      andCustomerIdentifier:(NSString*)customerIdentifier
                                        withCompletionBlock:(ASTProductPromoCodeBlock)completionBlock;

#pragma mark Get Basic Product Data from Server

// Obtaining a single product update from the server
- (ASTStoreProduct*)storeProductForProductIdentifier:(NSString*)productIdentifier;

typedef void (^ASTStoreProductBlock)(NSString *productIdentifier, 
                                     ASTStoreProduct *storeProduct);

- (void)asyncStoreProductForProductIdentifier:(NSString*)productIdentifier
                          withCompletionBlock:(ASTStoreProductBlock)completionBlock;


// Getting the whole set of product data available on the server
- (NSArray*)storeProducts;

typedef void (^ASTStoreProductArrayBlock)(NSArray *storeProductsArray);

- (void)asyncStoreProductsWithCompletionBlock:(ASTStoreProductArrayBlock)completionBlock;


@end
