//
//  ASTStoreProductPlistReader.m
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


#import "ASTStoreProductPlistReader.h"
#import "ASTStoreProduct.h"

@implementation ASTStoreProductPlistReader

+ (ASTStoreProductIdentifierType)stringToProductIdentifierType:(NSString*)typeAsString
{
    NSString *lowerTypeAsString = [typeAsString lowercaseString];
    
    if( [lowerTypeAsString isEqualToString:[kASTStoreProductPlistTypeConsumableKey lowercaseString]] )
    {
        return ( ASTStoreProductIdentifierTypeConsumable );
    }
    
    if( [lowerTypeAsString isEqualToString:[kASTStoreProductPlistTypeNonconsumableKey lowercaseString]] )
    {
        return ( ASTStoreProductIdentifierTypeNonconsumable );
    }

    if( [lowerTypeAsString isEqualToString:[kASTStoreProductPlistTypeAutoRenewable lowercaseString]] )
    {
        return ( ASTStoreProductIdentifierTypeAutoRenewable );
    }

    
    return ( ASTStoreProductIdentifierTypeInvalid );
}

+ (NSUInteger)stringToQuantity:(NSString*)quantityAsString fromType:(ASTStoreProductIdentifierType)aType
{
    DLog(@"string:%@ type:%d", quantityAsString, aType);
    
    if( aType == ASTStoreProductIdentifierTypeConsumable )
    {
        return ( [quantityAsString integerValue] );
    }
    
    if( aType == ASTStoreProductIdentifierTypeAutoRenewable )
    {
        NSString *lowerAutoRenewable = [quantityAsString lowercaseString];
        
        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity7Days lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType7Days );
        }
        
        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity1Month lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType1Month );
        }

        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity2Months lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType2Months );
        }

        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity3Months lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType2Months );
        }
        
        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity6Months lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType2Months );
        }

        if( [lowerAutoRenewable isEqualToString:[kASTStoreProductPlistAutoRenewQuantity1Year lowercaseString]] )
        {
            return ( ASTStoreProductAutoRenewableType1Year );
        }
    }
    
    return ( 0 );
}

+ (NSArray*)readStoreProductPlistFromFile:(NSString*)file
{
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:file];
    
    if( nil == plistArray )
    {
        DLog(@"Failed to read plist from file: %@", file);
        return ( nil );
    }
    
    NSMutableArray *tmpStoreProductArray = [[[NSMutableArray alloc] init] autorelease];
    
    for( NSDictionary *dict in plistArray )
    {
        NSString *identifier = [dict objectForKey:kASTStoreProductPlistIdentifierKey];
        NSString *typeAsString = [dict objectForKey:kASTStoreProductPlistTypeKey];
        NSString *familyIdentifier = nil;
        NSUInteger familyQuantity = 0;
        
        if(( nil == identifier ) || ( nil == typeAsString ))
        {
            DLog(@"Failed to read mandatory keys from plist (identifier:%p type:%p)",
                 identifier, typeAsString );
            continue;
        }
        
        ASTStoreProductIdentifierType type = [ASTStoreProductPlistReader stringToProductIdentifierType:typeAsString];
        
        if( type == ASTStoreProductIdentifierTypeInvalid )
        {
            DLog(@"Failed to read a valid type from plist file for identifier: %@", identifier);
            continue;
        }

        if(( ASTStoreProductIdentifierTypeConsumable == type ) || 
           ( ASTStoreProductIdentifierTypeAutoRenewable == type ))
        {
            familyIdentifier = [dict objectForKey:kASTStoreProductPlistTypeFamilyIdentifier];
            NSString *familyQuantityAsString = [dict objectForKey:kASTStoreProductPlistTypeFamilyQuantity];
            
            familyQuantity = [ASTStoreProductPlistReader stringToQuantity:familyQuantityAsString fromType:type];
        }
        else
        {
            // For Nonconsumable, set the familyIdentifier to the productId
            // and set the quantity to 1
            familyIdentifier = identifier;
            familyQuantity = 1;
        }
        
        ASTStoreProduct *aProduct = [ASTStoreProduct storeProductWithProductIdentifier:identifier 
                                                                                  type:type
                                                                      familyIdentifier:familyIdentifier 
                                                                        familyQuantity:familyQuantity];
        
        if( nil == aProduct )
        {
            DLog(@"Failed to instantiate ASTStoreProduct from plist file for identifier:%@", identifier);
            continue;
        }
        
        NSString *title = [dict objectForKey:kASTStoreProductPlistTitleKey];
        NSString *description = [dict objectForKey:kASTStoreProductPlistDescriptionKey];
        
        NSString *extraInformation = [dict objectForKey:kASTStoreProductPlistExtraInformation];
        NSString *minimumVersion = [dict objectForKey:kASTStoreProductPlistMinimumVersionKey];
        NSNumber *boolAsNumber = [dict objectForKey:kASTStoreProductPlistShouldDisplayKey];

        
        if( title )
        {
            aProduct.title = title;
        }
        
        if( description )
        {
            aProduct.description = description;
        }
        
        if( extraInformation )
        {
            aProduct.extraInformation = extraInformation;
        }
        
        if( minimumVersion )
        {
            aProduct.minimumVersion = minimumVersion;
        }
        
        if( boolAsNumber )
        {
            aProduct.shouldDisplay = [boolAsNumber boolValue];
        }
        
        [tmpStoreProductArray addObject:aProduct];
    }
    
    if( [tmpStoreProductArray count] == 0 )
    {
        DLog(@"Did not add any entries from plist file:%@", file);
        return nil;
    }
    
    return ( [NSArray arrayWithArray:tmpStoreProductArray] );
}

@end
