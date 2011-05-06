//
//  NSData+Encryption.m
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-04-14.
//  http://www.anystonetech.com

//  NOTE: This code is based on code from Karl as found on the following thread
//  http://www.cocos2d-iphone.org/forum/topic/6982 

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

#import "NSData+ASTEncryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import "SSKeychain.h"

@implementation NSData (ASTEncryption)

- (NSData*)astMakeCryptedVersionWithKeyData:(const void*)keyData ofLength:(int)keyLength decrypt:(bool)decrypt
{
	// Copy the key data, padding with zeroes if needed
	char key[kCCKeySizeAES256];
	bzero(key, sizeof(key));
	memcpy(key, keyData, keyLength > kCCKeySizeAES256 ? kCCKeySizeAES256 : keyLength);
    
	size_t bufferSize = [self length] + kCCBlockSizeAES128;
	void* buffer = malloc(bufferSize);
    
	size_t dataUsed;
    
	CCCryptorStatus status = CCCrypt(decrypt ? kCCDecrypt : kCCEncrypt,
									 kCCAlgorithmAES128,
									 kCCOptionPKCS7Padding | kCCOptionECBMode,
									 key, kCCKeySizeAES256,
									 NULL,
									 [self bytes], [self length],
									 buffer, bufferSize,
									 &dataUsed);
    
	switch(status)
	{
		case kCCSuccess:
			return [NSData dataWithBytesNoCopy:buffer length:dataUsed];
		case kCCParamError:
			NSLog(@"Error: NSDataAES256: Could not %s data: Param error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCBufferTooSmall:
			NSLog(@"Error: NSDataAES256: Could not %s data: Buffer too small", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCMemoryFailure:
			NSLog(@"Error: NSDataAES256: Could not %s data: Memory failure", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCAlignmentError:
			NSLog(@"Error: NSDataAES256: Could not %s data: Alignment error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCDecodeError:
			NSLog(@"Error: NSDataAES256: Could not %s data: Decode error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCUnimplemented:
			NSLog(@"Error: NSDataAES256: Could not %s data: Unimplemented", decrypt ? "decrypt" : "encrypt");
			break;
		default:
			NSLog(@"Error: NSDataAES256: Could not %s data: Unknown error", decrypt ? "decrypt" : "encrypt");
	}
    
	free(buffer);
	return nil;
}

- (NSData*)astEncryptWithKey:(NSData*) key
{
	return [self astMakeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:NO];
}

- (NSData*)astDecryptWithKey:(NSData*) key
{
	return [self astMakeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:YES];
}


@end
