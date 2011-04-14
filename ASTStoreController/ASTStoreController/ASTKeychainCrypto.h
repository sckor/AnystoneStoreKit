//
//  ASTKeychainCrypto.h
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-04-14.
//  http://www.anystonetech.com
//
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

@interface ASTKeychainCrypto : NSObject {}

+ (id)sharedASTKeychainCrypto;

// The following methods make use of SSKeychain to manage a randomly
// generated key that is stored securely in the keychain

// Generates a new encryption key, and stores it in the keychain
// If a key already exists, it will overwrite it 
// returns an NSData instance containing the new key
- (NSData*)generateEncryptionKey;

// Obtain an existing key from the keychain
// returns nil if the key does not exist
- (NSData*)retrieveEncryptionKey;

// Will use a cached copy of the key rather than retrieving from
// the keychain every time (which the retrieve would do).
// Will also automatically generate a new key if one does not exist
@property (nonatomic, retain) NSData *cachedKey;

// Encrypt or decrypt using the key in the keychain
// returns nil if no key has been generated
- (NSData*)encryptData:(NSData*)dataToEncrypt;
- (NSData*)decryptData:(NSData*)dataToDecrypt;

// Allows setting of service and account strings
// If not otherwise set, they will default to being the
// bundle identifier for the app
@property (nonatomic, copy) NSString *serviceString;
@property (nonatomic, copy) NSString *accountString;

@end
