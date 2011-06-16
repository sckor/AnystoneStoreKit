//
//  ASTStoreProductTypes.h
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

typedef enum
{
    ASTStoreProductIdentifierTypeInvalid,
    ASTStoreProductIdentifierTypeConsumable,
    ASTStoreProductIdentifierTypeNonconsumable,
    ASTStoreProductIdentifierTypeAutoRenewable
} ASTStoreProductIdentifierType;


#ifndef DEBUG

// Production server values
#define ASTStoreProductSecondsInDay ( 60 * 60 * 24 )
#define ASTStoreRenewalGracePeriodInSeconds (60 * 5) // 5 minutes

typedef enum
{
    ASTStoreProductAutoRenewableTypeInvalid = 0,
    ASTStoreProductAutoRenewableType7Days = 7 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableType1Month = 30 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableType2Months = 61 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableType3Months = 91 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableType6Months = 182 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableType1Year = 365 * ASTStoreProductSecondsInDay,
    ASTStoreProductAutoRenewableTypeMaximum
} ASTStoreProductAutoRenewableType;

#else

// Debug/Sandbox values
#define ASTStoreProductSecondsInMinute 60
#define ASTStoreRenewalGracePeriodInSeconds 10

typedef enum
{
    ASTStoreProductAutoRenewableTypeInvalid = 0,
    ASTStoreProductAutoRenewableType7Days = 3 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableType1Month = 5 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableType2Months = 10 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableType3Months = 15 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableType6Months = 30 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableType1Year = 60 * ASTStoreProductSecondsInMinute,
    ASTStoreProductAutoRenewableTypeMaximum
} ASTStoreProductAutoRenewableType;

#endif
