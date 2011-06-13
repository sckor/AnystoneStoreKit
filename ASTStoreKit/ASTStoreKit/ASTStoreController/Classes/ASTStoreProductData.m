//
//  ASTStoreProductData.m
//  ASTStoreController
//
//  Created by Sean Kormilo on 11-03-15.
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

#import "ASTStoreProductData.h"
#import "ASTStoreProductTypes.h"
#import "ASTStoreFamilyData.h"

#define k_PRODUCT_IDENTIFIER 						@"productIdentifier"
#define k_TYPE                                      @"type"
#define k_FAMILY_IDENTIFIER 						@"familyIdentifier"
#define k_FAMILY_QUANITY                            @"familyQuanity"


@interface ASTStoreProductData ()

- (void)save;
@property (nonatomic, copy) NSString *productDataPath;
@property (readonly, retain) ASTStoreFamilyData *familyData;

@property (nonatomic,copy) NSString *productIdentifier;
@property ASTStoreProductIdentifierType type;

@end

@implementation ASTStoreProductData

#pragma mark Synthesizers

@synthesize productIdentifier = productIdentifier_;
@synthesize type = type_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize familyQuanity = familyQuanity_;
@synthesize availableQuantity = availableQuantity_;
@synthesize productDataPath = productDataPath_;
@synthesize familyData = familyData_;

#pragma mark Private Class Methods
+ (NSString*)directoryForProductDataWithIdentifier:(NSString*)aProductIdentifier
{
    // Want to keep the product data in the following directory
    // <app>/Library/ASTStoreController/productData/aProductIdentifier
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)
                             objectAtIndex:0];
    
    NSString *directoryPath = [libraryPath stringByAppendingPathComponent:@"ASTStoreController/productData"];
    
    
    return ([directoryPath stringByAppendingPathComponent:aProductIdentifier]);
}

+ (NSString*)pathForProductDataWithIdentifier:(NSString*)aProductIdentifier
{
    // Want to keep the product data archive in the following file
    // <app>/Library/ASTStoreController/productData/aProductIdentifier/ASTStoreProductData.archive
    NSString *directoryPath = [ASTStoreProductData directoryForProductDataWithIdentifier:aProductIdentifier];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( NO == [fm fileExistsAtPath:directoryPath isDirectory:nil] )
    {
        NSError *error;
        BOOL result = [fm createDirectoryAtPath:directoryPath 
                    withIntermediateDirectories:YES 
                                     attributes:nil 
                                          error:&error];
        
        if( NO == result )
        {
            DLog(@"Failed to create directory:%@ error:%@", directoryPath, error);
            return nil;
        }
    }
    
    NSString *pathForProductData = [directoryPath stringByAppendingPathComponent:@"ASTStoreProductData"];
    
    return ( [pathForProductData stringByAppendingPathExtension:@"archive"] );
}



#pragma mark Class Methods
+ (ASTStoreProductData*)storeProductDataFromProductIdentifier:(NSString*)aProductIdentifier
{
    ASTStoreProductData *productData = nil;
    
    NSString *fileName = [ASTStoreProductData pathForProductDataWithIdentifier:aProductIdentifier];
    
    if( nil == fileName )
    {
        DLog(@"Failed to get filename for product id:%@", aProductIdentifier);
        return nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( NO == [fm fileExistsAtPath:fileName isDirectory:nil] )
    {
        // Cannot make this data up - must return nil
        DLog(@"Could not find productData:%@", fileName);
        return ( nil );
    }
    
    @try 
    {
        productData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    }
    @catch (NSException *exception) 
    {
        productData = nil;
    }
    
    if( nil == productData )
    {
        DLog(@"Unarchive failed for %@", fileName);
        return nil;
    }
    
    productData.productDataPath = fileName;
    
    return( productData );
}


+ (id)nonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier
{
    return ( [[[ASTStoreProductData alloc] 
               initNonConsumableStoreProductWithIdentifier:aProductIdentifier] 
              autorelease] );
}

+ (id)consumableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                          familyIdentifier:(NSString*)aFamilyIdentifier 
                            familyQuantity:(NSUInteger)aFamilyQuantity
{
    return ( [[[ASTStoreProductData alloc] 
               initConsumableStoreProductWithIdentifier:aProductIdentifier 
               familyIdentifier:aFamilyIdentifier 
               familyQuantity:aFamilyQuantity] 
              autorelease] );
}

+ (id)autoRenewableStoreProductWithIdentifier:(NSString*)aProductIdentifier 
                             familyIdentifier:(NSString*)aFamilyIdentifier 
                               familyQuantity:(ASTStoreProductAutoRenewableType)aFamilyQuantity
{
    return ( [[[ASTStoreProductData alloc] 
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
            return ( [ASTStoreProductData nonConsumableStoreProductWithIdentifier:aProductIdentifier] );
            break;
            
        case ASTStoreProductIdentifierTypeConsumable:
            return ( [ASTStoreProductData consumableStoreProductWithIdentifier:aProductIdentifier
                                                          familyIdentifier:aFamilyIdentifier
                                                            familyQuantity:aFamilyQuantity]); 
            break;
            
        case ASTStoreProductIdentifierTypeAutoRenewable:
#ifdef AUTORENEW_SUPPORTED
            return ( [ASTStoreProductData autoRenewableStoreProductWithIdentifier:aProductIdentifier
                                                             familyIdentifier:aFamilyIdentifier
                                                               familyQuantity:aFamilyQuantity] );
#else
            DLog(@"Renewable type not supported yet");
#endif
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
#ifdef AUTORENEW_SUPPORTED
        return YES;
#else
        DLog(@"Renewable type not supported yet");
#endif
    }
    
    return NO;
}



#pragma mark Private Methods

- (void)save
{
    BOOL result = [NSKeyedArchiver archiveRootObject:self toFile:self.productDataPath];
    
    if( ! result )
    {
        DLog(@"save failed for family:%@", self.productDataPath);
    }
    else
    {
        DLog(@"saved: %@", self.productDataPath);
    }
}

#pragma mark Synthesizer Override
- (NSString*)productDataPath
{
    if( nil != productDataPath_ )
    {
        return ( productDataPath_ );
    }
    
    productDataPath_ = [[ASTStoreProductData pathForProductDataWithIdentifier:self.productIdentifier] copy];
    
    return ( productDataPath_ );
}

- (ASTStoreFamilyData*)familyData
{
    if( nil != familyData_ )
    {
        return ( familyData_ );
    }
    
    familyData_ = [ASTStoreFamilyData familyDataWithIdentifier:self.familyIdentifier productType:self.type];
    [familyData_ retain];
    
    return ( familyData_ );
}
- (void)setFamilyQuanity:(NSUInteger)familyQuanity
{
    familyQuanity_ = familyQuanity;
    [self save];
}

- (NSUInteger)availableQuantity
{
    return ( self.familyData.availableQuantity );
}

- (void)setAvailableQuantity:(NSUInteger)availableQuantity
{
    self.familyData.availableQuantity = availableQuantity;
}

- (BOOL)isPurchased
{
    return self.familyData.isPurchased;
}

- (NSUInteger)consumeQuantity:(NSUInteger)amountToConsume
{
    return [self.familyData consumeQuantity:amountToConsume];
}

//---------------------------------------------------------- 
//  Keyed Archiving
//
//---------------------------------------------------------- 
- (void) encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.productIdentifier forKey:k_PRODUCT_IDENTIFIER];
    [encoder encodeInteger:self.type forKey:k_TYPE];
    [encoder encodeObject:self.familyIdentifier forKey:k_FAMILY_IDENTIFIER];
    [encoder encodeInteger:self.familyQuanity forKey:k_FAMILY_QUANITY];
}

- (id) initWithCoder: (NSCoder *)decoder 
{
    self = [super init];
    if (self)
    {
        self.productIdentifier = [decoder decodeObjectForKey:k_PRODUCT_IDENTIFIER];
        self.type = [decoder decodeIntegerForKey:k_TYPE];
        self.familyIdentifier = [decoder decodeObjectForKey:k_FAMILY_IDENTIFIER];
        self.familyQuanity = [decoder decodeIntegerForKey:k_FAMILY_QUANITY];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setProductIdentifier:[[self.productIdentifier copy] autorelease]];
    [theCopy setType:self.type];
    [theCopy setFamilyIdentifier:[[self.familyIdentifier copy] autorelease]];
    [theCopy setFamilyQuanity:self.familyQuanity];
    
    return theCopy;
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
    
    if( ! [ASTStoreProductData isStoreProductIdentifierTypeValid:aType] )
    {
        [self release];
        return nil;
    }
    
    type_ = aType;
    
    productIdentifier_ = [aProductIdentifier copy];    
    familyIdentifier_ = [aFamilyIdentifier copy];
    
    familyQuanity_= aFamilyQuantity;
    
    [self save];
    
    return self;
}

- (id)initNonConsumableStoreProductWithIdentifier:(NSString*)aProductIdentifier
{
    return ( [self initWithProductIdentifier:aProductIdentifier 
                                        type:ASTStoreProductIdentifierTypeNonconsumable 
                            familyIdentifier:aProductIdentifier 
                              familyQuantity:1] );
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

- (void)removeData
{
    // Remove the family data
    [familyData_ release];
    familyData_ = nil;
    
    [ASTStoreFamilyData removeFamilyDataForIdentifier:self.familyIdentifier];
    
    NSString *dirName = [ASTStoreProductData directoryForProductDataWithIdentifier:self.productIdentifier];
    
    if( nil == dirName )
    {
        DLog(@"Failed to get dirName for product id:%@", self.productIdentifier);
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( YES == [fm fileExistsAtPath:dirName isDirectory:nil] )
    {
        NSError *error;
        BOOL result = [fm removeItemAtPath:dirName error:&error];
        
        if( result )
        {
            DLog(@"Removed family data from disk for id:%@", dirName);
        }
        else
        {
            DLog(@"Remove family data failed for id:%@ error:%@", dirName, error);
        }
    }

    // Release and set to nil - if accessed again will force recreation of directory
    // and file on save
    [productDataPath_ release];
    productDataPath_ = nil;

}

- (void)dealloc 
{
    [productIdentifier_ release];
    productIdentifier_ = nil;
    
    [familyIdentifier_ release];
    familyIdentifier_ = nil;
    
    [productDataPath_ release];
    productDataPath_ = nil;
    
    [familyData_ release];
    familyData_ = nil;
    
    [super dealloc];
}

@end
