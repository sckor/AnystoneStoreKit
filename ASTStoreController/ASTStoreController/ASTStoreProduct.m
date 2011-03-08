//
//  ASTStoreProduct.m
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


#import "ASTStoreProduct.h"



@implementation ASTStoreProduct

@synthesize identifier = identifier_;
@synthesize minimumVersion = minimumVersion_;
@synthesize type = type_;
@synthesize shouldDisplay = shouldDisplay_;
@synthesize extraInformation = extraInformation_;
@synthesize skProduct = skProduct_;

+ (id)storeProductWithIdentifier:(NSString*)anIdentifier andType:(ASTStoreProductIdentifierType)aType
{
    ASTStoreProduct *product = [[[ASTStoreProduct alloc] 
                                 initWithProductIdentifier:anIdentifier andType:aType]
                                autorelease];
    
    return ( product );
}

+ (BOOL)isStoreProductIdentifierTypeValid:(ASTStoreProductIdentifierType)aType
{
    if( aType == ASTStoreProductIdentifierTypeConsumable )
    {
        return YES;
    }
    
    if( aType == ASTStoreProductIdentifierTypeNonconsumable )
    {
        return YES;
    }
    
    if( aType == ASTStoreProductIdentifierTypeAutoRenewable )
    {
        return YES;
    }
    
    return NO;
}

- (void)updateProductFromProduct:(ASTStoreProduct*)aProduct
{
    // Cannot update type, identifier or skProduct
    if( ! [self.minimumVersion isEqualToString:aProduct.minimumVersion] )
    {
        self.minimumVersion = aProduct.minimumVersion;
    }
    
    if( self.shouldDisplay != aProduct.shouldDisplay )
    {
        self.shouldDisplay = aProduct.shouldDisplay;
    }
    
    if( ! [self.extraInformation isEqualToString:aProduct.extraInformation] )
    {
        self.extraInformation = aProduct.extraInformation;
    }
    
}

- (id)initWithProductIdentifier:(NSString*)aProductIdentifier andType:(ASTStoreProductIdentifierType)aType
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    if( ! [ASTStoreProduct isStoreProductIdentifierTypeValid:aType] )
    {
        [self release];
        return nil;
    }
    
    type_ = aType;
    
    identifier_ = aProductIdentifier;
    [identifier_ retain];
    
    
    
    minimumVersion_ = nil;
    shouldDisplay_ = YES;
    extraInformation_ = nil;
    skProduct_ = nil;
    
    return self;
}

- (void)dealloc 
{
    
    [identifier_ release];
    identifier_ = nil;
    
    [minimumVersion_ release];
    minimumVersion_ = nil;
    
    [extraInformation_ release];
    extraInformation_ = nil;
    
    [super dealloc];
}

@end
