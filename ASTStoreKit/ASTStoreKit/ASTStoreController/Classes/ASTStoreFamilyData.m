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
#import "ASTKeychainCrypto.h"
#import "NSKeyedArchiver+Encryption.h"
#import "NSKeyedUnarchiver+Encryption.h"

#define k_FAMILY_IDENTIFIER 						@"familyIdentifier"
#define k_PURCHASED_QUANTITY 						@"purchasedQuantity"
#define k_TYPE                                      @"type"
#define k_RECEIPT 						@"receipt"
#define k_EXPIRES_DATE 						@"expiresDate"

static id<ASTStoreFamilyDataExpiryProtocol> astFamilyDataDelegate = nil;

@interface ASTStoreFamilyData()

- (void)save;

@property (nonatomic, copy) NSString *familyDataPath;
@property (copy) NSString *familyIdentifier;
@property (nonatomic,retain) NSTimer *expiryDateTimer;

@end

@implementation ASTStoreFamilyData

@synthesize availableQuantity = availableQuantity_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize familyDataPath = familyDataPath_;
@synthesize type = type_;
@synthesize receipt = receipt_;
@synthesize expiresDate = expiresDate_;
@synthesize expiryDateTimer = expiryDateTimer_;

#pragma mark private class methods
+ (NSMutableDictionary*)familyDataDictionary
{
    static dispatch_once_t pred;
    static NSMutableDictionary *familyDataDictionary_ = nil;
    
    dispatch_once(&pred, ^{ familyDataDictionary_ = [[NSMutableDictionary alloc] init]; });
    
    return ( familyDataDictionary_ );
}

+ (void)setFamilyDataDelegate:(id<ASTStoreFamilyDataExpiryProtocol>)delegate
{
    astFamilyDataDelegate = delegate;
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

+ (NSString*)appendEncryptionNameToPathForFamilyData:(NSString*)pathForFamilyData
{
    NSString *tmp = [pathForFamilyData stringByDeletingPathExtension];
    
    return ( [tmp stringByAppendingPathExtension:@"enc-archive"] );
}

+ (ASTStoreFamilyData*)createFamilyData:(NSString*)aFamilyIdentifier productType:(ASTStoreProductIdentifierType)productType
{
    ASTStoreFamilyData *familyData = [[[ASTStoreFamilyData alloc] initWithFamilyIdentifier:aFamilyIdentifier] autorelease];
    familyData.type = productType;
    
    
    [[ASTStoreFamilyData familyDataDictionary] setObject:familyData forKey:aFamilyIdentifier];

    [familyData save];
    
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

    NSString *encFileName = [ASTStoreFamilyData appendEncryptionNameToPathForFamilyData:fileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // See if encrypted version exists first - as that will be the default now
    if( YES == [fm fileExistsAtPath:encFileName isDirectory:nil] )
    {
        @try 
        {
            ASTKeychainCrypto *kc = [ASTKeychainCrypto sharedASTKeychainCrypto];
            NSData *key = kc.cachedKey;
            familyData = [NSKeyedUnarchiver decryptArchiveObjectWithFile:encFileName usingKey:key];
        }
        @catch (NSException *exception) 
        {
            familyData = nil;
        }
    }
    else if( YES == [fm fileExistsAtPath:fileName isDirectory:nil] )
    {
        // No encrypted file exists, so attempt to read from non-encrypted archive
        @try 
        {
            familyData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
            
            if( familyData )
            {
                if( familyData.type == ASTStoreProductIdentifierTypeInvalid )
                {
                    // This may be necessary for old family data which did not have a type
                    familyData.type = productType;
                }
                
                // Invoke a save since the old file is about to be removed
                [familyData save];
            }
        }
        @catch (NSException *exception) 
        {
            familyData = nil;
        }
        
        // Now remove it - do not want to keep old format around
        [fm removeItemAtPath:fileName error:nil];
    }
    
    if(( nil != familyData ) && ( YES == [familyData isKindOfClass:[ASTStoreFamilyData class]] ))
    {
        [[ASTStoreFamilyData familyDataDictionary] setObject:familyData forKey:aFamilyIdentifier];
    }
    else if( createIfNeeded )
    {
        familyData = [ASTStoreFamilyData createFamilyData:aFamilyIdentifier productType:productType];        
    }
    else
    {
        return nil;
    }
    
    familyData.familyDataPath = encFileName;
    
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
    
    NSString *encFileName = [ASTStoreFamilyData appendEncryptionNameToPathForFamilyData:fileName];

    if( YES == [fm fileExistsAtPath:encFileName isDirectory:nil] )
    {
        NSError *error;
        BOOL result = [fm removeItemAtPath:encFileName error:&error];
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

#pragma mark Private Methods

- (void)invokeDelegateAstFamilyDataVerifySubscriptionForFamilyData:(ASTStoreFamilyData*)familyData
{
    if (astFamilyDataDelegate && [astFamilyDataDelegate respondsToSelector:@selector(astFamilyDataVerifySubscriptionForFamilyData:)])
    {
        [astFamilyDataDelegate astFamilyDataVerifySubscriptionForFamilyData:familyData];
    }
}

- (void)familyDataVerifySubscriptionTimerInvoked:(NSTimer*)timer
{
    [self invokeDelegateAstFamilyDataVerifySubscriptionForFamilyData:self];
}

#pragma mark Synthesizer Override
- (BOOL)isPurchased
{
    if( self.type == ASTStoreProductIdentifierTypeAutoRenewable )
    {
        if( nil == self.expiresDate )
        {
            return NO;
        }
        
        NSDate *now = [NSDate date];
        NSDate *expDate = self.expiresDate;
        
        if( self.expiryDateTimer )
        {
            // Take into account grace period - this gives a chance for a timer to
            // run and pull latest status to catch any auto renewals that may have happened
            expDate = [self.expiryDateTimer fireDate];
        }
        
        DLog(@"now:%@ expires:%@ grace:%@", now, self.expiresDate, expDate );
        
        if( NSOrderedDescending == [now compare:expDate] )
        {
            return NO;
        }
        
        return YES;
    }
    
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
    
    NSString *fileName = [ASTStoreFamilyData pathForFamilyDataWithIdentifier:self.familyIdentifier];
    familyDataPath_ = [[ASTStoreFamilyData appendEncryptionNameToPathForFamilyData:fileName] 
                       copy];
    
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

- (void)setReceipt:(NSString *)receipt
{
    if( receipt_ != receipt )
    {
        [receipt_ release];
        receipt_ = [receipt copy];
        
        [self save];
    }    
}


- (void)setExpiresDate:(NSDate *)anExpiresDate
{
    if (expiresDate_ != anExpiresDate)
    {
        [anExpiresDate retain];
        [expiresDate_ release];
        expiresDate_ = anExpiresDate;
        
        if( nil != expiresDate_ )
        {
            NSDate *now = [NSDate date];

            if( NSOrderedAscending == [now compare:expiresDate_] )
            {
                // expiresDate is in the future - create a timer to
                // fire off when that time passes + a bit of a 
                // grace period
                NSTimeInterval expireInterval = 
                [expiresDate_ timeIntervalSinceReferenceDate] - [now timeIntervalSinceReferenceDate];
                
                expireInterval += ASTStoreRenewalGracePeriodInSeconds;
                
                self.expiryDateTimer = [NSTimer scheduledTimerWithTimeInterval:expireInterval 
                                                                        target:self 
                                                                      selector:@selector(familyDataVerifySubscriptionTimerInvoked:)
                                                                      userInfo:nil 
                                                                       repeats:NO];
                DLog(@"set expiry timer for: %f", expireInterval);
            }

        }
        
        [self save];
    }
}

- (NSMutableDictionary*)familyDataDictionary
{
    return [ASTStoreFamilyData familyDataDictionary];
}

- (void)setExpiryDateTimer:(NSTimer *)expiryDateTimer
{
    if( nil != expiryDateTimer_ )
    {
        [expiryDateTimer_ invalidate];
        [expiryDateTimer_ release];
        expiryDateTimer_ = nil;
    }
    
    expiryDateTimer_ = [expiryDateTimer retain];
}

#pragma mark Private Methods

- (void)save
{
    ASTKeychainCrypto *kc = [ASTKeychainCrypto sharedASTKeychainCrypto];
    
    NSData *key = kc.cachedKey;
    
    BOOL result = [NSKeyedArchiver encryptArchiveRootObject:self toFile:self.familyDataPath usingKey:key];
    
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
    [encoder encodeObject:self.receipt forKey:k_RECEIPT];
    [encoder encodeObject: self.expiresDate forKey: k_EXPIRES_DATE];

}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    
    if (self)
    {
        familyIdentifier_ = [[decoder decodeObjectForKey:k_FAMILY_IDENTIFIER] copy];
        availableQuantity_ = [decoder decodeIntegerForKey:k_PURCHASED_QUANTITY];
        type_ = [decoder decodeIntegerForKey:k_TYPE];
        receipt_ = [[decoder decodeObjectForKey:k_RECEIPT] copy];
        
        // use the accessor so it will set any timers as necessary
        self.expiresDate = [decoder decodeObjectForKey: k_EXPIRES_DATE];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setFamilyIdentifier: [[self.familyIdentifier copy] autorelease]];
    [theCopy setAvailableQuantity: self.availableQuantity];
    [theCopy setType:self.type];
    [theCopy setReceipt:[[self.receipt copy] autorelease]];
    [theCopy setExpiresDate:[[self.expiresDate copy] autorelease]];

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
    
    [receipt_ release], receipt_ = nil;
    [expiresDate_ release], expiresDate_ = nil;
    
    if( nil != expiryDateTimer_ )
    {
        [expiryDateTimer_ invalidate];
        [expiryDateTimer_ release];
        expiryDateTimer_ = nil;
    }
        
    [super dealloc];
}

@end
