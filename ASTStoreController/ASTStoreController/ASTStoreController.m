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

#define kASTStoreControllerDefaultNetworkTimeout 60

@interface ASTStoreController() <SKProductsRequestDelegate>

@property (readonly) NSMutableDictionary *storeProductDictionary;
@property ASTStoreControllerProductDataState productDataState;
@property (retain) SKProductsRequest *skProductsRequest;
@end


@implementation ASTStoreController

#pragma mark Synthesis
@synthesize storeProductDictionary = storeProductDictionary_;
@synthesize productDataState = productDataState_;
@synthesize delegate = delegate_;
@synthesize networkTimeoutDuration = networkTimeoutDuration_;
@synthesize skProductsRequest = skProductsRequest_;

#pragma mark Accessors

- (NSMutableDictionary*)storeProductDictionary
{
    if( nil != storeProductDictionary_ )
    {
        return ( storeProductDictionary_ );
    }
    
    storeProductDictionary_ = [[NSMutableDictionary alloc] init];
    
    return ( storeProductDictionary_ );
}

#pragma mark Product Setup

- (void)setProductIdentifierFromStoreProduct:(ASTStoreProduct*)storeProduct
{
    
    ASTStoreProduct *existingProduct = [self.storeProductDictionary objectForKey:storeProduct.identifier];
    
    if( existingProduct )
    {
        [existingProduct updateProductFromProduct:storeProduct];
    }
    else
    {
        [self.storeProductDictionary setObject:storeProduct forKey:storeProduct.identifier];
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
    
    return( YES );
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
    
    return( result );
}


- (void)setProductIdentifiersAsyncFromNetworkURL:(NSURL*)plistURL toPlistPath:(NSString*)path withCompletionHandler:(void (^)(NSError*))handler
{
    DLog(@"Not implemented yet");
}


- (void)setProductIdentifier:(NSString*)productIdentifier forType:(ASTStoreProductIdentifierType)type;
{
    ASTStoreProduct *aProduct = [ASTStoreProduct storeProductWithIdentifier:productIdentifier andType:type];
    
    if( nil == aProduct )
    {
        DLog(@"Failed to create product for id:%@ type:%d", productIdentifier, type);
        return;
    }

    [self setProductIdentifierFromStoreProduct:aProduct];
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
    
}

#pragma mark Purchase
- (void)purchase:(NSString*)productIdentifier
{
    
}

- (void)purchaseStoreProduct:(ASTStoreProduct*)storeProduct
{
    
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
        return( nil );
    }

    productDataState_ = ASTStoreControllerProductDataStateUnknown;
    delegate_ = nil;
    networkTimeoutDuration_ = kASTStoreControllerDefaultNetworkTimeout;
    
    return self;
}

- (void)dealloc
{
    // See opinions expressed here for why this asserts:
    // http://www.mikeash.com/pyblog/friday-qa-2009-10-02-care-and-feeding-of-singletons.html
    ALog(@"Should not be releasing a singleton!");
}

@end
