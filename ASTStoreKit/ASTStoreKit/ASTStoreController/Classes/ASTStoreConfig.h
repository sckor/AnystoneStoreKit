//
//  ASTStoreConfig.h
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-14.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASTStoreConfig : NSObject {}

@property (readonly, copy) NSString *productPlistFile;
@property (readonly) NSTimeInterval retryStoreConnectionInterval;
@property (readonly, copy) NSURL *serverURL;
@property (readonly) NSTimeInterval serverConnectionTimeout;
@property (readonly, copy) NSString *vendorUuid;
@property (readonly) BOOL verifyReceipts;
@property (readonly) BOOL serverPromoCodesEnabled;
@property (readonly) BOOL serverConsumablesEnabled;
@property (readonly, copy) NSDictionary *serviceURLPaths;

@end
