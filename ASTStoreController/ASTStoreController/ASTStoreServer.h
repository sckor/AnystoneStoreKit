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

@protocol ASTStoreServerDelegate;

typedef enum
{
    ASTStoreServerReceiptVerificationResultPass,
    ASTStoreServerReceiptVerificationResultFail,
    ASTStoreServerReceiptVerificationResultInconclusive
} ASTStoreServerReceiptVerificationResult;

#define kASTStoreServerDefaultNetworkTimeout 15.0

@interface ASTStoreServer : NSObject 
{
    NSURL *serverUrl_;
    NSTimeInterval serverConnectionTimeout_;
    
    id<ASTStoreServerDelegate> delegate_;
}

+ (NSString*)productIdentifierForTransaction:(SKPaymentTransaction*)transaction;

- (ASTStoreServerReceiptVerificationResult)verifyTransaction:(SKPaymentTransaction*)transaction; 


// Uses delegate method to provide result
- (void)asyncVerifyTransaction:(SKPaymentTransaction*)transaction;

// Uses blocks to provide result - completion block runs on global default
// queue - use dispatch_async(dispatch_get_main_queue()) inside the completion block if it needs to run
// on the main thread
typedef void (^ASTVerifyReceiptBlock)(SKPaymentTransaction* transaction,
                                      ASTStoreServerReceiptVerificationResult result);

- (void)asyncVerifyTransaction:(SKPaymentTransaction*)transaction
           withCompletionBlock:(ASTVerifyReceiptBlock)completionBlock;

@property (retain) NSURL *serverUrl;
@property  NSTimeInterval serverConnectionTimeout;
@property (assign) id<ASTStoreServerDelegate> delegate;

@end

@protocol ASTStoreServerDelegate <NSObject>
@optional

// Delegate is called to provide result for async receipt verification result
- (void)astStoreServerVerifiedTransaction:(SKPaymentTransaction*)transaction 
                               withResult:(ASTStoreServerReceiptVerificationResult)result;



@end
