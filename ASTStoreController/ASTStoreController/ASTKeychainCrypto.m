//
//  ASTKeychainCrypto.m
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

#import "ASTKeychainCrypto.h"
#import "NSData+Encryption.h"
#import "SSKeychain.h"

@interface ASTKeychainCrypto ()

@property (readonly) NSString *bundleId;

@end

@implementation ASTKeychainCrypto

@synthesize serviceString = serviceString_;
@synthesize accountString = accountString_;
@synthesize cachedKey = cachedKey_;
@synthesize bundleId = bundleId_;

+ (id)sharedASTKeychainCrypto
{
    static dispatch_once_t pred;
    static ASTKeychainCrypto *aSTKeychainCrypto = nil;
    
    dispatch_once(&pred, ^{ aSTKeychainCrypto = [[self alloc] init]; });
    return aSTKeychainCrypto;
}

- (NSString*)bundleId
{
    if( nil != bundleId_ )
    {
        return [[bundleId_ retain] autorelease];
    }
    
    bundleId_ = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [bundleId_ retain];
    
    return [[bundleId_ retain] autorelease];
}

- (NSString*)serviceString
{
    if( nil != serviceString_ )
    {
        return( [[serviceString_ retain] autorelease] );
    }
    
    serviceString_ = [self.bundleId copy];
    return [[serviceString_ retain] autorelease];
}

- (NSString*)accountString
{
    if( nil != accountString_ )
    {
        return ( [[accountString_ retain] autorelease] );
    }
    
    accountString_ = [self.bundleId copy];
    return [[accountString_ retain] autorelease];
}

- (NSData*)cachedKey
{
    if( nil != cachedKey_ )
    {
        return( [[cachedKey_ retain] autorelease] );
    }
    
    NSData *retrieveData = [self retrieveEncryptionKey];
    
    if( nil == retrieveData )
    {
        retrieveData = [self generateEncryptionKey];
    }
    
    self.cachedKey = retrieveData;

    return [[cachedKey_ retain] autorelease];
}

- (NSData*)generateEncryptionKey
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *uuidAsString = (NSString*) CFUUIDCreateString(NULL, theUUID);
    NSData *keyAsData = nil;
    
    NSError *error = nil;
    
    BOOL result = [SSKeychain setPassword:uuidAsString 
                               forService:self.serviceString 
                                  account:self.accountString 
                                    error:&error];
    
    if( YES == result )
    {
        CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(theUUID);
        keyAsData = [NSData dataWithBytes:&uuidBytes length:sizeof(uuidBytes)];
    }
    else
    {
        DLog(@"Failed to store encryption key: %@ %@ %@ error:%@",
             uuidAsString,
             self.serviceString,
             self.accountString,
             error);
    }
    
    
    [uuidAsString release];
    CFRelease(theUUID);
    
    return( keyAsData );
}

- (NSData*)retrieveEncryptionKey
{
    NSError *error = nil;    
    NSString *uuidAsString = [SSKeychain passwordForService:self.serviceString
                                                    account:self.accountString
                                                      error:&error];
    if( nil == uuidAsString )
    {
        DLog(@"Failed to retrieve encryption key for: %@ %@ error:%@",
             self.serviceString,
             self.accountString,
             error);
        
        return nil;
    }
    
    CFUUIDRef theUUID = CFUUIDCreateFromString(NULL, (CFStringRef) uuidAsString);
    CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(theUUID);
    
    NSData *keyAsData = [NSData dataWithBytes:&uuidBytes length:sizeof(uuidBytes)];

    CFRelease(theUUID);
        
    return( keyAsData );
}

- (NSData*)encryptData:(NSData *)dataToEncrypt
{
    NSData *key = self.cachedKey;
    
    if( nil == key )
    {
        return nil;
    }
    
    return( [dataToEncrypt encryptWithKey:key] );
}

- (NSData*)decryptData:(NSData *)dataToDecrypt
{
    NSData *key = self.cachedKey;
    
    if( nil == key )
    {
        return nil;
    }
    
    return( [dataToDecrypt decryptWithKey:key] );
}


- (id)init 
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    
    return self;
}

- (void)dealloc 
{
    ALog(@"Should not be releasing a singleton class");
    [super dealloc];
}


@end
