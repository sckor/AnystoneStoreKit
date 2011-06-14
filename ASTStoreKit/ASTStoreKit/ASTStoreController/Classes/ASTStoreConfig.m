//
//  ASTStoreConfig.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-14.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import "ASTStoreConfig.h"
#import "ASTStoreConfig+Private.h"

@implementation ASTStoreConfig

@synthesize productPlistFile = productPlistFile_;
@synthesize retryStoreConnectionInterval = retryStoreConnectionInterval_;
@synthesize serverURL = serverURL_;
@synthesize serverConnectionTimeout = serverConnectionTimeout_;
@synthesize vendorUuid = vendorUuid_;
@synthesize verifyReceipts = verifyReceipts_;
@synthesize serverPromoCodesEnabled = serverPromoCodesEnabled_;
@synthesize serverConsumablesEnabled = serverConsumablesEnabled_;
@synthesize serviceURLPaths = serviceURLPaths_;

- (id)init 
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    productPlistFile_ = nil;
    retryStoreConnectionInterval_ = 15.0;
    serverURL_ = nil;
    serverConnectionTimeout_ = 15.0;
    vendorUuid_ = nil;
    verifyReceipts_ = NO;
    serverPromoCodesEnabled_ = NO;
    serverConsumablesEnabled_ = NO;
    serviceURLPaths_ = nil;
    
    return self;
}


- (void)dealloc 
{
    [productPlistFile_ release], productPlistFile_ = nil;
    [serverURL_ release], serverURL_ = nil;
    [vendorUuid_ release], vendorUuid_ = nil;
    [serviceURLPaths_ release], serviceURLPaths_ = nil;
    
    [super dealloc];
}

@end
