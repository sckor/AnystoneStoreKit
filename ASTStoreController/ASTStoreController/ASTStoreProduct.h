//
//  ASTStoreProduct.h
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-03-08.
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

typedef enum
{
    ASTStoreProductIdentifierTypeInvalid,
    ASTStoreProductIdentifierTypeConsumable,
    ASTStoreProductIdentifierTypeNonconsumable,
    ASTStoreProductIdentifierTypeAutoRenewable
} ASTStoreProductIdentifierType;

@interface ASTStoreProduct : NSObject 
{
    NSString *productIdentifier_;
    ASTStoreProductIdentifierType type_;

    NSString *title_;
    NSString *description_;
    
    NSString *minimumVersion_;
    NSString *extraInformation_;    
    BOOL shouldDisplay_;
    BOOL isValid_;
}

+ (id)storeProductWithIdentifier:(NSString*)anIdentifier andType:(ASTStoreProductIdentifierType)aType;
- (id)initWithProductIdentifier:(NSString*)anIdentifier andType:(ASTStoreProductIdentifierType)aType;

@property (readonly) NSString *productIdentifier;
@property (readonly) ASTStoreProductIdentifierType type;

// Title to send back from localizedTitle if title has not been obtained from app store
@property (retain) NSString *title;

// Description to return from localizedDescription if the description has not been obtained from
// the app store
@property (retain) NSString *description;

// Can be used to prevent displaying of in app purchases in older versions of the app
// which do not support it yet
@property (retain) NSString *minimumVersion;

// An extra string to display in the store, such as "On sale 50% off for a limited time!"
@property (retain) NSString *extraInformation;

// Hint to the store view controller whether this item should show up in the list
@property BOOL shouldDisplay;

// Defaults to YES; Will be set to NO if iTunes returns that the product
// is invalid upon querying for it
@property  (readonly) BOOL isValid;

// The following properties are valid when the data has been retrieved from
// iTunes by the ASTStoreController; If there is not data, the methods
// will return nil. See SKProduct for more information
@property(nonatomic, readonly) NSString *localizedPrice;
@property(nonatomic, readonly) NSString *localizedDescription;
@property(nonatomic, readonly) NSString *localizedTitle;
@property(nonatomic, readonly) NSDecimalNumber *price;
@property(nonatomic, readonly) NSLocale *priceLocale;


@end
