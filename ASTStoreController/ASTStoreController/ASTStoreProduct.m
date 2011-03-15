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


#import "ASTStoreProduct+Private.h"

@implementation ASTStoreProduct

@synthesize productIdentifier = productIdentifier_;
@synthesize minimumVersion = minimumVersion_;
@synthesize type = type_;
@synthesize shouldDisplay = shouldDisplay_;
@synthesize extraInformation = extraInformation_;
@synthesize skProduct = skProduct_;
@synthesize isValid = isValid_;
@synthesize title = title_;
@synthesize description = description_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize familyQuanity = familyQuanity_;

#pragma mark Class Methods

+ (id)nonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier
{
    return ( [[[ASTStoreProduct alloc] 
               initNonConsumableStoreProductWithIdentifier:aProductIdentifier] 
              autorelease] );
}

+ (id)consumableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                          familyIdentifier:(NSString*)aFamilyIdentifier 
                            familyQuantity:(NSUInteger)aFamilyQuantity
{
    return ( [[[ASTStoreProduct alloc] 
               initConsumableStoreProductWithIdentifier:aProductIdentifier 
               familyIdentifier:aFamilyIdentifier 
               familyQuantity:aFamilyQuantity] 
              autorelease] );
}

+ (id)autoRenewableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                             familyIdentifier:(NSString*)aFamilyIdentifier 
                               familyQuantity:(ASTStoreProductAutoRenewableType)aFamilyQuantity
{
    return ( [[[ASTStoreProduct alloc] 
               initAutoRenewableStoreProductWithIdentifier:aProductIdentifier
               familyIdentifier:aFamilyIdentifier 
               familyQuantity:aFamilyQuantity] 
              autorelease] );
}

+ (id)storeProductWithProductIdentifier:(NSString*)aProductIdentifier 
                                   type:(ASTStoreProductIdentifierType)aType
                       familyIdentifier:(NSString*)aFamilyIdentifier
                         familyQuantity:(NSUInteger)aFamilyQuantity
{
    switch (aType) 
    {
        case ASTStoreProductIdentifierTypeNonconsumable:
            return ( [ASTStoreProduct nonConsumableStoreProductWithIdentifier:aProductIdentifier] );
            break;
            
        case ASTStoreProductIdentifierTypeConsumable:
            return ( [ASTStoreProduct consumableStoreProductWithIdentifier:aProductIdentifier
                                                          familyIdentifier:aFamilyIdentifier
                                                            familyQuantity:aFamilyQuantity]); 
            break;
            
        case ASTStoreProductIdentifierTypeAutoRenewable:
            return ( [ASTStoreProduct autoRenewableStoreProductWithIdentifier:aProductIdentifier
                                                             familyIdentifier:aFamilyIdentifier
                                                               familyQuantity:aFamilyQuantity] );
        default:
            break;
    }
    
    return ( nil );
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

#pragma mark Private Methods

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
    
    if( self.familyQuanity != aProduct.familyQuanity )
    {
        self.familyQuanity = aProduct.familyQuanity;
    }
    
    if( ! [self.title isEqualToString:aProduct.title] )
    {
        self.title = aProduct.title;
    }
    
    if( self.shouldDisplay != aProduct.shouldDisplay )
    {
        self.shouldDisplay = aProduct.shouldDisplay;
    }
}

#pragma mark SKProduct related properties

- (NSString*)localizedPrice
{
    if( nil == self.skProduct )
    {
        return ( nil );
    }
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.skProduct.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.skProduct.price];
    
    return ( formattedString );
}

- (NSString*)localizedDescription
{
    if( nil == self.skProduct )
    {
        return ( self.description );
    }
    
    return ( self.skProduct.localizedDescription );
}

- (NSString*)localizedTitle
{
    if( nil == self.skProduct )
    {
        return ( self.title );
    }
    
    return ( self.skProduct.localizedTitle );
}

- (NSDecimalNumber*)price
{
    if( nil == self.skProduct )
    {
        return ( nil );
    }
    
    return ( self.skProduct.price );
}

- (NSLocale*)priceLocale
{
    if( nil == self.skProduct )
    {
        return ( nil );
    }
    
    return ( self.skProduct.priceLocale );
}

#pragma mark Init and Dealloc


- (id)initWithProductIdentifier:(NSString*)aProductIdentifier 
                           type:(ASTStoreProductIdentifierType)aType
               familyIdentifier:(NSString*)aFamilyIdentifier
                 familyQuantity:(NSUInteger)aFamilyQuantity
{
    self = [super init];
    
    if( nil == self) 
    {
        return ( nil );
    }
    
    if( ! [ASTStoreProduct isStoreProductIdentifierTypeValid:aType] )
    {
        [self release];
        return nil;
    }
    
    type_ = aType;
    
    productIdentifier_ = aProductIdentifier;
    [productIdentifier_ retain];
    
    familyIdentifier_ = aFamilyIdentifier;
    [familyIdentifier_ retain];
    
    familyQuanity_= aFamilyQuantity;
    
    minimumVersion_ = nil;
    title_ = nil;
    description_ = nil;
    shouldDisplay_ = YES;
    extraInformation_ = nil;
    skProduct_ = nil;
    isValid_ = YES;
    
    return self;
}

- (id)initNonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier
{
    return ( [self initWithProductIdentifier:aProductIdentifier 
                                       type:ASTStoreProductIdentifierTypeNonconsumable 
                           familyIdentifier:nil 
                             familyQuantity:0] );
}

- (id)initConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                              familyIdentifier:(NSString*)aFamilyIdentifier 
                                familyQuantity:(NSUInteger)aFamilyQuantity
{
    if(( nil == aFamilyIdentifier ) || ( [aFamilyIdentifier isEqualToString:@""] ))
    {
        DLog(@"Family Identifier must be set for a Consumable product");
        [self release];
        return ( nil );
    }
    
    if( 0 == aFamilyQuantity )
    {
        DLog(@"Family quantity must be > 0 for a Consumable product");
        [self release];
        return ( nil );
    }
    
    return ( [self initWithProductIdentifier:aProductIdentifier 
                                       type:ASTStoreProductIdentifierTypeConsumable 
                           familyIdentifier:aFamilyIdentifier
                             familyQuantity:aFamilyQuantity] );

}

- (id)initAutoRenewableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                                 familyIdentifier:(NSString*)aFamilyIdentifier 
                                   familyQuantity:(ASTStoreProductAutoRenewableType)aFamilyQuantity
{
    if(( nil == aFamilyIdentifier ) || ( [aFamilyIdentifier isEqualToString:@""] ))
    {
        DLog(@"Family Identifier must be set for an AutoRenewable product");

        [self release];
        return ( nil );
    }
    
    if(( ASTStoreProductAutoRenewableTypeInvalid == aFamilyQuantity ) ||
       ( aFamilyQuantity >= ASTStoreProductAutoRenewableTypeMaximum ))
    {
        DLog(@"Family quantity must be > 0 for an AutoRenewable product");

        [self release];
        return ( nil );
    }
    
    return ( [self initWithProductIdentifier:aProductIdentifier 
                                       type:ASTStoreProductIdentifierTypeConsumable 
                           familyIdentifier:aFamilyIdentifier
                             familyQuantity:aFamilyQuantity] );
}



- (void)dealloc 
{
    [productIdentifier_ release];
    productIdentifier_ = nil;
    
    [minimumVersion_ release];
    minimumVersion_ = nil;
    
    [extraInformation_ release];
    extraInformation_ = nil;
    
    [skProduct_ release];
    skProduct_ = nil;
    
    [title_ release];
    title_ = nil;
    
    [description_ release];
    description_ = nil;
    
    [familyIdentifier_ release];
    familyIdentifier_ = nil;
    
    [super dealloc];
}

@end
