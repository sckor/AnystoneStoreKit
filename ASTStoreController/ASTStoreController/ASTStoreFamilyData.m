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

@interface ASTStoreFamilyData()

- (void)save;

@property (nonatomic, retain) NSString *familyDataPath;
@property (retain) NSString *familyIdentifier;

@end

@implementation ASTStoreFamilyData

@synthesize availableQuantity = availableQuantity_;
@synthesize familyIdentifier = familyIdentifier_;
@synthesize familyDataPath = familyDataPath_;

#pragma mark private class methods
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


#pragma mark public class methods
+ (ASTStoreFamilyData*)familyDataWithIdentifier:(NSString*)aFamilyIdentifier
{
    ASTStoreFamilyData *familyData = nil;
    
    NSString *fileName = [ASTStoreFamilyData pathForFamilyDataWithIdentifier:aFamilyIdentifier];
    
    if( nil == fileName )
    {
        DLog(@"Failed to get filename for family id:%@", aFamilyIdentifier);
        return nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if( NO == [fm fileExistsAtPath:fileName isDirectory:nil] )
    {
        // File does not exist - create a new instance
        familyData = [[[ASTStoreFamilyData alloc] initWithFamilyIdentifier:aFamilyIdentifier] autorelease];
        [familyData save];
        return ( familyData );
    }
    
    familyData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];    
    familyData.familyDataPath = fileName;

    return( familyData );
}


#pragma mark Synthesizer Override
- (NSString*)familyDataPath
{
    if( nil != familyDataPath_ )
    {
        return ( familyDataPath_ );
    }
    
    familyDataPath_ = [ASTStoreFamilyData pathForFamilyDataWithIdentifier:self.familyIdentifier];
    [familyDataPath_ retain];
    
    return ( familyDataPath_ );
}

- (void)setAvailableQuantity:(NSUInteger)newQuantity
{
    availableQuantity_ = newQuantity;
    
    [self save];
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
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    
    if (self)
    {
        self.familyIdentifier = [decoder decodeObjectForKey:k_FAMILY_IDENTIFIER];
        self.availableQuantity = [decoder decodeIntegerForKey:k_PURCHASED_QUANTITY];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setFamilyIdentifier: [[self.familyIdentifier copy] autorelease]];
    [theCopy setAvailableQuantity: self.availableQuantity];
    
    return theCopy;
}

- (id)initWithFamilyIdentifier:(NSString*)aFamilyIdentifier 
{
    self = [super init];
    
    if( nil == self) 
    {
        return( nil );
    }
    
    familyIdentifier_ = aFamilyIdentifier;
    [familyIdentifier_ retain];
    
    familyDataPath_ = nil;
    availableQuantity_ = 0;
    
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
