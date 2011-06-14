//
//  ASTStoreConfigPlistReader.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-14.
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


#import "ASTStoreConfigPlistReader.h"
#import "ASTStoreConfigKeys.h"
#import "ASTStoreConfig+Private.h"

@implementation ASTStoreConfigPlistReader



+ (ASTStoreConfig*)readStoreConfigFromPlistFile:(NSString*)plistFile
{
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    ASTStoreConfig *storeConfig = ASTAllocIA(ASTStoreConfig);
    
    if( nil == plistDictionary )
    {
        DLog(@"Failed to read dictionary from plist file:%@", plistFile);
        return nil;
    }
    
    NSNumber *aNumber = nil;
    NSString *aString = nil;
    
    storeConfig.productPlistFile = [plistDictionary objectForKey:kASTStoreConfigProductPlistFileKey];
    
    aNumber = [plistDictionary objectForKey:kASTStoreConfigRetryStoreConnectionIntervalKey];
    if( nil == aNumber )
    {
        storeConfig.retryStoreConnectionInterval = 15.0;
    }
    else
    {
        storeConfig.retryStoreConnectionInterval = [aNumber doubleValue];
    }
    
    aString = [plistDictionary objectForKey:kASTStoreConfigServerURLKey];
    if( nil != aString )
    {
        storeConfig.serverURL = [NSURL URLWithString:aString];
    }
    
    aNumber = [plistDictionary objectForKey:kASTStoreConfigServerConnectionTimeoutKey];
    if( nil == aNumber )
    {
        storeConfig.serverConnectionTimeout = 15.0;
    }
    else
    {
        storeConfig.serverConnectionTimeout = [aNumber doubleValue];
    }

    storeConfig.vendorUuid = [plistDictionary objectForKey:kASTStoreConfigVendorUUIDKey];
    
    aNumber = [plistDictionary objectForKey:kASTStoreConfigVerifyReceiptsKey];
    if( nil == aNumber )
    {
        storeConfig.verifyReceipts = NO;
    }
    else
    {
        storeConfig.verifyReceipts = [aNumber boolValue];
    }

    aNumber = [plistDictionary objectForKey:kASTStoreConfigServerPromoCodesEnabledKey];
    if( nil == aNumber )
    {
        storeConfig.serverPromoCodesEnabled = NO;
    }
    else
    {
        storeConfig.serverPromoCodesEnabled = [aNumber boolValue];
    }

    aNumber = [plistDictionary objectForKey:kASTStoreConfigServerConsumablesEnabledKey];
    if( nil == aNumber )
    {
        storeConfig.serverConsumablesEnabled = NO;
    }
    else
    {
        storeConfig.serverConsumablesEnabled = [aNumber boolValue];
    }

    storeConfig.serviceURLPaths = [plistDictionary objectForKey:kASTStoreConfigServiceURLPaths];
    
    return storeConfig;
}

@end
