//
//  ASTStoreFamilyData.m
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

#import "ASTStoreFamilyData.h"

#define k_FAMILY_IDENTIFIER 						@"familyIdentifier"
#define k_PURCHASED_QUANTITY 						@"purchasedQuantity"
#define k_TYPE                                      @"type"


@interface ASTStoreFamilyData()

- (void)save;

@property (nonatomic, copy) NSString *familyDataPath;
@property (copy) NSString *familyIdentifier;

@end

@implementation ASTStoreFamilyData

@synthesize availableQuantity = availableQuantity_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize familyDataPath = familyDataPath_;
@synthesize type = type_;

#pragma mark private class methods
+ (NSMutableDictionary*)familyDataDictionary
{
    static dispatch_once_t pred;
    static NSMutableDictionary *familyDataDictionary_ = nil;
    
    dispatch_once(&pred, ^{ familyDataDictionary_ = [[NSMutableDictionary alloc] init]; });
    
    return ( familyDataDictionary_ );
}


+ (NSString*)pathForFamilyDataWithIdentifier:(NSString*)aFamilyIdentifier
{
    // Want to keep the family data in the following directory
    // <app>/Library/ASTStoreController/familyData/aFamilyIdentifier.archive
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)
                             objectAtIndex:0];
    
    NSString *directoryPath = [libraryPath stringByAppendingPathComponent:@"ASTStoreController/familyData"];
    
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
    
    NSString *pathForFamilyData = [directoryPath stringByAppendingPathComponent:aFamilyIdentifier];

    return ( [pathForFamilyData stringByAppendingPathExtension:@"archive"] );
}

+ (ASTStoreFamilyData*)createFamilyData:(NSString*)aFamilyIdentifier productType:(ASTStoreProductIdentifierType)productType
{
    ASTStoreFamilyData *familyData = [[[ASTStoreFamilyData alloc] initWithFamilyIdentifier:aFamilyIdentifier] autorelease];
    familyData.type = productType;
    
    [familyData save];
    [[ASTStoreFamilyData familyDataDictionary] setObject:familyData forKey:aFamilyIdentifier];
    
    return familyData;
}

+ (ASTStoreFamilyData*)familyDataWithIdentifier:(NSString*)aFamilyIdentifier productType:(ASTStoreProductIdentifierType)productType createIfNeeded:(BOOL)createIfNeeded
{
    // Only want 1 instance of the family data across the process, so cache them in a dictionary
    ASTStoreFamilyData *familyData = [[ASTStoreFamilyData familyDataDictionary] objectForKey:aFamilyIdentifier];
    
    if( nil != familyData )
    {
        return familyData;
    }
    
    
    NSString *fileName = [ASTStoreFamilyData pathForFamilyDataWithIdentifier:aFamilyIdentifier];
    
    if( nil == fileName )
    {
        DLog(@"Failed to get filename for family id:%@", aFamilyIdentifier);
        return nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( NO == [fm fileExistsAtPath:fileName isDirectory:nil] )
    {
        if( createIfNeeded )
        {
            return( [ASTStoreFamilyData createFamilyData:aFamilyIdentifier productType:productType] );
        }
        else
        {
            return nil;
        }
    }
    
    @try 
    {
        familyData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    }
    @catch (NSException *exception) 
    {
        familyData = nil;
    }
    
    if( nil == familyData )
    {
        if( createIfNeeded )
        {
            // Unarchive failed - create a new one
            DLog(@"Unarchive failed for %@", fileName);
            return( [ASTStoreFamilyData createFamilyData:aFamilyIdentifier productType:productType] );
        }
        else
        {
            return nil;
        }
    }
    
    
    familyData.familyDataPath = fileName;
    
    if( familyData.type == ASTStoreProductIdentifierTypeInvalid )
    {
        // This may be necessary for old family data which did not have a type
        familyData.type = productType;
    }
    
    [[ASTStoreFamilyData familyDataDictionary] setObject:familyData forKey:aFamilyIdentifier];
    
    return( familyData );    
}

#pragma mark public class methods

+ (ASTStoreFamilyData*)familyDataWithIdentifier:(NSString*)aFamilyIdentifier
{
    return [ASTStoreFamilyData familyDataWithIdentifier:aFamilyIdentifier 
                                            productType:ASTStoreProductIdentifierTypeInvalid 
                                         createIfNeeded:NO];
}

+ (ASTStoreFamilyData*)familyDataWithIdentifier:(NSString*)aFamilyIdentifier productType:(ASTStoreProductIdentifierType)productType
{
    return [ASTStoreFamilyData familyDataWithIdentifier:aFamilyIdentifier 
                                            productType:productType 
                                         createIfNeeded:YES];
}



+ (void)removeFamilyDataForIdentifier:(NSString*)aFamilyIdentifier
{
    ASTStoreFamilyData *familyData = [[ASTStoreFamilyData familyDataDictionary] objectForKey:aFamilyIdentifier];
    
    if( nil != familyData )
    {
        [[ASTStoreFamilyData familyDataDictionary] removeObjectForKey:aFamilyIdentifier];
        DLog(@"Removed family data from memory for id:%@", aFamilyIdentifier);
    }
    
    NSString *fileName = [ASTStoreFamilyData pathForFamilyDataWithIdentifier:aFamilyIdentifier];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( YES == [fm fileExistsAtPath:fileName isDirectory:nil] )
    {
        NSError *error;
        BOOL result = [fm removeItemAtPath:fileName error:&error];
        if( result )
        {
            DLog(@"Removed family data from disk for id:%@", aFamilyIdentifier);
        }
        else
        {
            DLog(@"Remove family data failed for id:%@ error:%@", aFamilyIdentifier, error);
        }
    }
}

#pragma mark Synthesizer Override
- (BOOL)isPurchased
{
    NSUInteger quantity = self.availableQuantity;
    
    if(( quantity > 0 ) && ( self.type != ASTStoreProductIdentifierTypeConsumable ))
    {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)consumeQuantity:(NSUInteger)amountToConsume
{
    if( self.type != ASTStoreProductIdentifierTypeConsumable )
    {
        return 0;
    }
    
    NSUInteger currentQuantity = self.availableQuantity;
    NSUInteger consumeQuantity = amountToConsume;
    
    if( currentQuantity < consumeQuantity )
    {
        consumeQuantity = currentQuantity;
    }
    
    // Update the amount of consumables in the family
    currentQuantity -= consumeQuantity;
    self.availableQuantity = currentQuantity;
    
    return consumeQuantity;
}

- (NSString*)familyDataPath
{
    if( nil != familyDataPath_ )
    {
        return ( familyDataPath_ );
    }
    
    familyDataPath_ = [[ASTStoreFamilyData pathForFamilyDataWithIdentifier:self.familyIdentifier] copy];
    
    return ( familyDataPath_ );
}


- (void)setAvailableQuantity:(NSUInteger)newQuantity
{
    NSUInteger quantity = newQuantity;
    
    if(( self.type != ASTStoreProductIdentifierTypeConsumable ) && ( quantity > 1 ))
    {
        quantity = 1;
    }
    
    DLog(@"Updating quanity to %d for %@", quantity, self.familyIdentifier);
    availableQuantity_ = quantity;
    
    [self save];
}

- (NSMutableDictionary*)familyDataDictionary
{
    return [ASTStoreFamilyData familyDataDictionary];
}

#pragma mark Private Methods

- (void)save
{
    BOOL result = [NSKeyedArchiver archiveRootObject:self toFile:self.familyDataPath];
    
    if( ! result )
    {
        DLog(@"save failed for family:%@", self.familyDataPath);
    }
    else
    {
        DLog(@"saved: %@", self.familyDataPath);
    }
}

//---------------------------------------------------------- 
//  Keyed Archiving
//
//---------------------------------------------------------- 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.familyIdentifier forKey:k_FAMILY_IDENTIFIER];
    [encoder encodeInteger:self.availableQuantity forKey:k_PURCHASED_QUANTITY];
    [encoder encodeInteger:self.type forKey:k_TYPE];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    
    if (self)
    {
        familyIdentifier_ = [[decoder decodeObjectForKey:k_FAMILY_IDENTIFIER] copy];
        availableQuantity_ = [decoder decodeIntegerForKey:k_PURCHASED_QUANTITY];
        type_ = [decoder decodeIntegerForKey:k_TYPE];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setFamilyIdentifier: [[self.familyIdentifier copy] autorelease]];
    [theCopy setAvailableQuantity: self.availableQuantity];
    [theCopy setType:self.type];
    
    return theCopy;
}

- (id)initWithFamilyIdentifier:(NSString*)aFamilyIdentifier 
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    familyIdentifier_ = [aFamilyIdentifier copy];
    
    familyDataPath_ = nil;
    availableQuantity_ = 0;
    type_ = ASTStoreProductIdentifierTypeInvalid;
    
    [self save];
    
    return self;
}

- (id)init
{
    return [self initWithFamilyIdentifier:nil];
}

- (void)dealloc 
{
    [familyIdentifier_ release];
    familyIdentifier_ = nil;
    
    [familyDataPath_ release];
    familyDataPath_ = nil;
    
    [super dealloc];
}

@end
