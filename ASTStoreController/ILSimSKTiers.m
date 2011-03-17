

//
//  ILSimSKTiers.m
//  SimStoreKit
//
//  Created by ∞ on 02/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSimStoreKit.h"
#if kILSimAllowSimulatedStoreKit


#import "ILSimSKTiers.h"
#import "ILSimSKPaymentQueue.h"

NSString* const kILSimStorefront_EUR = @"EUR";
NSString* const kILSimStorefront_NZD = @"NZD";
NSString* const kILSimStorefront_DKK = @"DKK";
NSString* const kILSimStorefront_AUD = @"AUD";
NSString* const kILSimStorefront_MXP = @"MXP";
NSString* const kILSimStorefront_CAD = @"CAD";
NSString* const kILSimStorefront_USD = @"USD";
NSString* const kILSimStorefront_JPY = @"JPY";
NSString* const kILSimStorefront_GBP = @"GBP";
NSString* const kILSimStorefront_NOK = @"NOK";


static NSString* storefront = nil;

static BOOL ILSimSKIsKnownStorefront(NSString* sf) {
	return [sf isEqual:kILSimStorefront_USD] || [sf isEqual:kILSimStorefront_CAD] ||
		[ILSimSKAllTierPricesByStorefront() objectForKey:sf] != nil;
}

NSString* ILSimSKCurrentStorefront() {
	if (!storefront) {
		NSString* e = [[[NSProcessInfo processInfo] environment] objectForKey:kILSimSKStorefrontCodeEnvironmentVariable];
		if (!e || !ILSimSKIsKnownStorefront(e))
			e = kILSimStorefront_USD;
		ILSimSKSetCurrentStorefront(e);
	}
	
	return storefront;
}
	
void ILSimSKSetCurrentStorefront(NSString* s) {
	if (storefront != s) {
		[storefront release];
		storefront = [s copy];
	}
}

#define ILSimDec(mantissaValue, exponentValue) \
	[NSDecimalNumber decimalNumberWithMantissa:(mantissaValue) exponent:(exponentValue) isNegative:NO]

NSDictionary* ILSimSKAllTierPricesByStorefront() {
	static NSDictionary* prices = nil; if (!prices)
		prices =
		[[NSDictionary alloc] initWithObjectsAndKeys:
		  
		  [NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(79, -2),
ILSimDec(159, -2),
ILSimDec(239, -2),
ILSimDec(299, -2),
ILSimDec(399, -2),
ILSimDec(499, -2),
ILSimDec(549, -2),
ILSimDec(599, -2),
ILSimDec(699, -2),
ILSimDec(799, -2),
ILSimDec(899, -2),
ILSimDec(999, -2),
ILSimDec(1049, -2),
ILSimDec(1099, -2),
ILSimDec(1199, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1449, -2),
ILSimDec(1499, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1799, -2),
ILSimDec(1849, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2099, -2),
ILSimDec(2149, -2),
ILSimDec(2199, -2),
ILSimDec(2299, -2),
ILSimDec(2399, -2),
ILSimDec(2499, -2),
ILSimDec(2549, -2),
ILSimDec(2599, -2),
ILSimDec(2699, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2949, -2),
ILSimDec(2999, -2),
ILSimDec(3099, -2),
ILSimDec(3199, -2),
ILSimDec(3299, -2),
ILSimDec(3349, -2),
ILSimDec(3399, -2),
ILSimDec(3499, -2),
ILSimDec(3599, -2),
ILSimDec(3699, -2),
ILSimDec(3749, -2),
ILSimDec(3799, -2),
ILSimDec(3899, -2),
ILSimDec(3999, -2),
ILSimDec(4299, -2),
ILSimDec(4499, -2),
ILSimDec(4999, -2),
ILSimDec(5499, -2),
ILSimDec(5999, -2),
ILSimDec(6299, -2),
ILSimDec(6499, -2),
ILSimDec(6999, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8499, -2),
ILSimDec(8999, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10999, -2),
ILSimDec(11999, -2),
ILSimDec(12499, -2),
ILSimDec(12999, -2),
ILSimDec(13999, -2),
ILSimDec(14999, -2),
ILSimDec(15999, -2),
ILSimDec(16999, -2),
ILSimDec(17999, -2),
ILSimDec(18999, -2),
ILSimDec(19999, -2),
ILSimDec(23999, -2),
ILSimDec(27999, -2),
ILSimDec(31999, -2),
ILSimDec(35999, -2),
ILSimDec(39999, -2),
ILSimDec(47999, -2),
ILSimDec(55999, -2),
ILSimDec(63999, -2),
ILSimDec(71999, -2),
ILSimDec(79999, -2),
nil], @"EUR",
[NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(129, -2),
ILSimDec(259, -2),
ILSimDec(419, -2),
ILSimDec(529, -2),
ILSimDec(649, -2),
ILSimDec(829, -2),
ILSimDec(999, -2),
ILSimDec(1099, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1499, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1799, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2099, -2),
ILSimDec(2299, -2),
ILSimDec(2399, -2),
ILSimDec(2499, -2),
ILSimDec(2599, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2999, -2),
ILSimDec(3099, -2),
ILSimDec(3299, -2),
ILSimDec(3499, -2),
ILSimDec(3599, -2),
ILSimDec(3699, -2),
ILSimDec(3899, -2),
ILSimDec(3999, -2),
ILSimDec(4099, -2),
ILSimDec(4199, -2),
ILSimDec(4399, -2),
ILSimDec(4499, -2),
ILSimDec(4599, -2),
ILSimDec(4699, -2),
ILSimDec(4799, -2),
ILSimDec(4899, -2),
ILSimDec(4999, -2),
ILSimDec(5099, -2),
ILSimDec(5199, -2),
ILSimDec(5399, -2),
ILSimDec(5499, -2),
ILSimDec(5599, -2),
ILSimDec(5699, -2),
ILSimDec(5899, -2),
ILSimDec(5999, -2),
ILSimDec(6099, -2),
ILSimDec(6499, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8499, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10499, -2),
ILSimDec(10999, -2),
ILSimDec(11499, -2),
ILSimDec(11999, -2),
ILSimDec(12499, -2),
ILSimDec(14999, -2),
ILSimDec(15999, -2),
ILSimDec(16999, -2),
ILSimDec(17999, -2),
ILSimDec(19999, -2),
ILSimDec(20999, -2),
ILSimDec(22999, -2),
ILSimDec(23999, -2),
ILSimDec(24999, -2),
ILSimDec(25999, -2),
ILSimDec(26999, -2),
ILSimDec(27999, -2),
ILSimDec(28999, -2),
ILSimDec(29999, -2),
ILSimDec(31999, -2),
ILSimDec(39999, -2),
ILSimDec(44999, -2),
ILSimDec(49999, -2),
ILSimDec(54999, -2),
ILSimDec(64999, -2),
ILSimDec(74999, -2),
ILSimDec(84999, -2),
ILSimDec(94999, -2),
ILSimDec(104999, -2),
ILSimDec(124999, -2),
nil], @"NZD",
[NSArray arrayWithObjects:
ILSimDec(0, 0),
ILSimDec(6, 0),
ILSimDec(12, 0),
ILSimDec(18, 0),
ILSimDec(24, 0),
ILSimDec(30, 0),
ILSimDec(36, 0),
ILSimDec(42, 0),
ILSimDec(48, 0),
ILSimDec(54, 0),
ILSimDec(59, 0),
ILSimDec(69, 0),
ILSimDec(75, 0),
ILSimDec(79, 0),
ILSimDec(85, 0),
ILSimDec(89, 0),
ILSimDec(99, 0),
ILSimDec(105, 0),
ILSimDec(109, 0),
ILSimDec(115, 0),
ILSimDec(119, 0),
ILSimDec(125, 0),
ILSimDec(129, 0),
ILSimDec(135, 0),
ILSimDec(139, 0),
ILSimDec(149, 0),
ILSimDec(155, 0),
ILSimDec(159, 0),
ILSimDec(165, 0),
ILSimDec(169, 0),
ILSimDec(179, 0),
ILSimDec(185, 0),
ILSimDec(189, 0),
ILSimDec(195, 0),
ILSimDec(199, 0),
ILSimDec(209, 0),
ILSimDec(215, 0),
ILSimDec(219, 0),
ILSimDec(225, 0),
ILSimDec(229, 0),
ILSimDec(239, 0),
ILSimDec(245, 0),
ILSimDec(249, 0),
ILSimDec(255, 0),
ILSimDec(259, 0),
ILSimDec(269, 0),
ILSimDec(275, 0),
ILSimDec(279, 0),
ILSimDec(285, 0),
ILSimDec(289, 0),
ILSimDec(299, 0),
ILSimDec(319, 0),
ILSimDec(339, 0),
ILSimDec(369, 0),
ILSimDec(399, 0),
ILSimDec(439, 0),
ILSimDec(469, 0),
ILSimDec(499, 0),
ILSimDec(529, 0),
ILSimDec(559, 0),
ILSimDec(599, 0),
ILSimDec(629, 0),
ILSimDec(669, 0),
ILSimDec(699, 0),
ILSimDec(749, 0),
ILSimDec(819, 0),
ILSimDec(899, 0),
ILSimDec(929, 0),
ILSimDec(969, 0),
ILSimDec(1039, 0),
ILSimDec(1119, 0),
ILSimDec(1199, 0),
ILSimDec(1269, 0),
ILSimDec(1349, 0),
ILSimDec(1399, 0),
ILSimDec(1499, 0),
ILSimDec(1799, 0),
ILSimDec(1999, 0),
ILSimDec(2399, 0),
ILSimDec(2699, 0),
ILSimDec(2999, 0),
ILSimDec(3499, 0),
ILSimDec(3999, 0),
ILSimDec(4799, 0),
ILSimDec(5499, 0),
ILSimDec(5999, 0),
nil], @"DKK",
[NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(119, -2),
ILSimDec(249, -2),
ILSimDec(399, -2),
ILSimDec(499, -2),
ILSimDec(599, -2),
ILSimDec(799, -2),
ILSimDec(899, -2),
ILSimDec(999, -2),
ILSimDec(1199, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1499, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1799, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2199, -2),
ILSimDec(2299, -2),
ILSimDec(2399, -2),
ILSimDec(2499, -2),
ILSimDec(2699, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2999, -2),
ILSimDec(3199, -2),
ILSimDec(3299, -2),
ILSimDec(3399, -2),
ILSimDec(3499, -2),
ILSimDec(3699, -2),
ILSimDec(3799, -2),
ILSimDec(3899, -2),
ILSimDec(3999, -2),
ILSimDec(4199, -2),
ILSimDec(4299, -2),
ILSimDec(4399, -2),
ILSimDec(4499, -2),
ILSimDec(4599, -2),
ILSimDec(4699, -2),
ILSimDec(4799, -2),
ILSimDec(4899, -2),
ILSimDec(4999, -2),
ILSimDec(5199, -2),
ILSimDec(5299, -2),
ILSimDec(5399, -2),
ILSimDec(5499, -2),
ILSimDec(5699, -2),
ILSimDec(5799, -2),
ILSimDec(5899, -2),
ILSimDec(5999, -2),
ILSimDec(6999, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8999, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10499, -2),
ILSimDec(10999, -2),
ILSimDec(11499, -2),
ILSimDec(11999, -2),
ILSimDec(13999, -2),
ILSimDec(14999, -2),
ILSimDec(15999, -2),
ILSimDec(16999, -2),
ILSimDec(18999, -2),
ILSimDec(19999, -2),
ILSimDec(21999, -2),
ILSimDec(22999, -2),
ILSimDec(23999, -2),
ILSimDec(24999, -2),
ILSimDec(25999, -2),
ILSimDec(26999, -2),
ILSimDec(27999, -2),
ILSimDec(28999, -2),
ILSimDec(29999, -2),
ILSimDec(34999, -2),
ILSimDec(39999, -2),
ILSimDec(44999, -2),
ILSimDec(49999, -2),
ILSimDec(59999, -2),
ILSimDec(69999, -2),
ILSimDec(79999, -2),
ILSimDec(89999, -2),
ILSimDec(99999, -2),
ILSimDec(119999, -2),
nil], @"AUD",
[NSArray arrayWithObjects:
ILSimDec(0, 0),
ILSimDec(10, 0),
ILSimDec(20, 0),
ILSimDec(30, 0),
ILSimDec(40, 0),
ILSimDec(50, 0),
ILSimDec(60, 0),
ILSimDec(70, 0),
ILSimDec(80, 0),
ILSimDec(90, 0),
ILSimDec(100, 0),
ILSimDec(120, 0),
ILSimDec(130, 0),
ILSimDec(140, 0),
ILSimDec(150, 0),
ILSimDec(160, 0),
ILSimDec(170, 0),
ILSimDec(180, 0),
ILSimDec(190, 0),
ILSimDec(200, 0),
ILSimDec(210, 0),
ILSimDec(220, 0),
ILSimDec(230, 0),
ILSimDec(240, 0),
ILSimDec(250, 0),
ILSimDec(260, 0),
ILSimDec(270, 0),
ILSimDec(280, 0),
ILSimDec(290, 0),
ILSimDec(300, 0),
ILSimDec(320, 0),
ILSimDec(330, 0),
ILSimDec(340, 0),
ILSimDec(350, 0),
ILSimDec(360, 0),
ILSimDec(370, 0),
ILSimDec(380, 0),
ILSimDec(390, 0),
ILSimDec(400, 0),
ILSimDec(410, 0),
ILSimDec(420, 0),
ILSimDec(430, 0),
ILSimDec(440, 0),
ILSimDec(450, 0),
ILSimDec(460, 0),
ILSimDec(470, 0),
ILSimDec(480, 0),
ILSimDec(490, 0),
ILSimDec(500, 0),
ILSimDec(520, 0),
ILSimDec(530, 0),
ILSimDec(580, 0),
ILSimDec(630, 0),
ILSimDec(680, 0),
ILSimDec(740, 0),
ILSimDec(790, 0),
ILSimDec(840, 0),
ILSimDec(900, 0),
ILSimDec(950, 0),
ILSimDec(1000, 0),
ILSimDec(1050, 0),
ILSimDec(1200, 0),
ILSimDec(1300, 0),
ILSimDec(1400, 0),
ILSimDec(1500, 0),
ILSimDec(1600, 0),
ILSimDec(1700, 0),
ILSimDec(1800, 0),
ILSimDec(1900, 0),
ILSimDec(2000, 0),
ILSimDec(2100, 0),
ILSimDec(2200, 0),
ILSimDec(2300, 0),
ILSimDec(2400, 0),
ILSimDec(2500, 0),
ILSimDec(2600, 0),
ILSimDec(3200, 0),
ILSimDec(3700, 0),
ILSimDec(4200, 0),
ILSimDec(4700, 0),
ILSimDec(5300, 0),
ILSimDec(6300, 0),
ILSimDec(7400, 0),
ILSimDec(8500, 0),
ILSimDec(9500, 0),
ILSimDec(10500, 0),
nil], @"MXP",
[NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(99, -2),
ILSimDec(199, -2),
ILSimDec(299, -2),
ILSimDec(399, -2),
ILSimDec(499, -2),
ILSimDec(599, -2),
ILSimDec(699, -2),
ILSimDec(799, -2),
ILSimDec(899, -2),
ILSimDec(999, -2),
ILSimDec(1099, -2),
ILSimDec(1199, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1499, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1799, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2099, -2),
ILSimDec(2199, -2),
ILSimDec(2299, -2),
ILSimDec(2399, -2),
ILSimDec(2499, -2),
ILSimDec(2599, -2),
ILSimDec(2699, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2999, -2),
ILSimDec(3099, -2),
ILSimDec(3199, -2),
ILSimDec(3299, -2),
ILSimDec(3399, -2),
ILSimDec(3499, -2),
ILSimDec(3599, -2),
ILSimDec(3699, -2),
ILSimDec(3799, -2),
ILSimDec(3899, -2),
ILSimDec(3999, -2),
ILSimDec(4099, -2),
ILSimDec(4199, -2),
ILSimDec(4299, -2),
ILSimDec(4399, -2),
ILSimDec(4499, -2),
ILSimDec(4599, -2),
ILSimDec(4699, -2),
ILSimDec(4799, -2),
ILSimDec(4899, -2),
ILSimDec(4999, -2),
ILSimDec(5499, -2),
ILSimDec(5999, -2),
ILSimDec(6499, -2),
ILSimDec(6999, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8499, -2),
ILSimDec(8999, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10999, -2),
ILSimDec(11999, -2),
ILSimDec(12999, -2),
ILSimDec(13999, -2),
ILSimDec(14999, -2),
ILSimDec(15999, -2),
ILSimDec(16999, -2),
ILSimDec(17999, -2),
ILSimDec(18999, -2),
ILSimDec(19999, -2),
ILSimDec(20999, -2),
ILSimDec(21999, -2),
ILSimDec(22999, -2),
ILSimDec(23999, -2),
ILSimDec(24999, -2),
ILSimDec(29999, -2),
ILSimDec(34999, -2),
ILSimDec(39999, -2),
ILSimDec(44999, -2),
ILSimDec(49999, -2),
ILSimDec(59999, -2),
ILSimDec(69999, -2),
ILSimDec(79999, -2),
ILSimDec(89999, -2),
ILSimDec(99999, -2),
nil], @"CAD",
[NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(99, -2),
ILSimDec(199, -2),
ILSimDec(299, -2),
ILSimDec(399, -2),
ILSimDec(499, -2),
ILSimDec(599, -2),
ILSimDec(699, -2),
ILSimDec(799, -2),
ILSimDec(899, -2),
ILSimDec(999, -2),
ILSimDec(1099, -2),
ILSimDec(1199, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1499, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1799, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2099, -2),
ILSimDec(2199, -2),
ILSimDec(2299, -2),
ILSimDec(2399, -2),
ILSimDec(2499, -2),
ILSimDec(2599, -2),
ILSimDec(2699, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2999, -2),
ILSimDec(3099, -2),
ILSimDec(3199, -2),
ILSimDec(3299, -2),
ILSimDec(3399, -2),
ILSimDec(3499, -2),
ILSimDec(3599, -2),
ILSimDec(3699, -2),
ILSimDec(3799, -2),
ILSimDec(3899, -2),
ILSimDec(3999, -2),
ILSimDec(4099, -2),
ILSimDec(4199, -2),
ILSimDec(4299, -2),
ILSimDec(4399, -2),
ILSimDec(4499, -2),
ILSimDec(4599, -2),
ILSimDec(4699, -2),
ILSimDec(4799, -2),
ILSimDec(4899, -2),
ILSimDec(4999, -2),
ILSimDec(5499, -2),
ILSimDec(5999, -2),
ILSimDec(6499, -2),
ILSimDec(6999, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8499, -2),
ILSimDec(8999, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10999, -2),
ILSimDec(11999, -2),
ILSimDec(12999, -2),
ILSimDec(13999, -2),
ILSimDec(14999, -2),
ILSimDec(15999, -2),
ILSimDec(16999, -2),
ILSimDec(17999, -2),
ILSimDec(18999, -2),
ILSimDec(19999, -2),
ILSimDec(20999, -2),
ILSimDec(21999, -2),
ILSimDec(22999, -2),
ILSimDec(23999, -2),
ILSimDec(24999, -2),
ILSimDec(29999, -2),
ILSimDec(34999, -2),
ILSimDec(39999, -2),
ILSimDec(44999, -2),
ILSimDec(49999, -2),
ILSimDec(59999, -2),
ILSimDec(69999, -2),
ILSimDec(79999, -2),
ILSimDec(89999, -2),
ILSimDec(99999, -2),
nil], @"USD",
[NSArray arrayWithObjects:
ILSimDec(0, 0),
ILSimDec(115, 0),
ILSimDec(230, 0),
ILSimDec(350, 0),
ILSimDec(450, 0),
ILSimDec(600, 0),
ILSimDec(700, 0),
ILSimDec(800, 0),
ILSimDec(900, 0),
ILSimDec(1000, 0),
ILSimDec(1200, 0),
ILSimDec(1300, 0),
ILSimDec(1400, 0),
ILSimDec(1500, 0),
ILSimDec(1600, 0),
ILSimDec(1700, 0),
ILSimDec(1800, 0),
ILSimDec(2000, 0),
ILSimDec(2100, 0),
ILSimDec(2200, 0),
ILSimDec(2300, 0),
ILSimDec(2400, 0),
ILSimDec(2500, 0),
ILSimDec(2600, 0),
ILSimDec(2800, 0),
ILSimDec(2900, 0),
ILSimDec(3000, 0),
ILSimDec(3100, 0),
ILSimDec(3200, 0),
ILSimDec(3300, 0),
ILSimDec(3500, 0),
ILSimDec(3600, 0),
ILSimDec(3700, 0),
ILSimDec(3800, 0),
ILSimDec(3900, 0),
ILSimDec(4000, 0),
ILSimDec(4100, 0),
ILSimDec(4300, 0),
ILSimDec(4400, 0),
ILSimDec(4500, 0),
ILSimDec(4600, 0),
ILSimDec(4700, 0),
ILSimDec(4800, 0),
ILSimDec(4900, 0),
ILSimDec(5000, 0),
ILSimDec(5200, 0),
ILSimDec(5300, 0),
ILSimDec(5400, 0),
ILSimDec(5500, 0),
ILSimDec(5600, 0),
ILSimDec(5800, 0),
ILSimDec(6000, 0),
ILSimDec(7000, 0),
ILSimDec(7500, 0),
ILSimDec(8000, 0),
ILSimDec(8500, 0),
ILSimDec(9000, 0),
ILSimDec(10000, 0),
ILSimDec(10500, 0),
ILSimDec(11000, 0),
ILSimDec(11500, 0),
ILSimDec(13000, 0),
ILSimDec(14000, 0),
ILSimDec(15000, 0),
ILSimDec(16000, 0),
ILSimDec(18000, 0),
ILSimDec(19000, 0),
ILSimDec(20000, 0),
ILSimDec(21000, 0),
ILSimDec(22000, 0),
ILSimDec(23000, 0),
ILSimDec(24000, 0),
ILSimDec(25000, 0),
ILSimDec(26000, 0),
ILSimDec(27000, 0),
ILSimDec(29000, 0),
ILSimDec(35000, 0),
ILSimDec(40000, 0),
ILSimDec(45000, 0),
ILSimDec(50000, 0),
ILSimDec(58000, 0),
ILSimDec(70000, 0),
ILSimDec(80000, 0),
ILSimDec(90000, 0),
ILSimDec(100000, 0),
ILSimDec(115000, 0),
nil], @"JPY",
[NSArray arrayWithObjects:
ILSimDec(0, -2),
ILSimDec(59, -2),
ILSimDec(119, -2),
ILSimDec(179, -2),
ILSimDec(239, -2),
ILSimDec(299, -2),
ILSimDec(349, -2),
ILSimDec(399, -2),
ILSimDec(499, -2),
ILSimDec(549, -2),
ILSimDec(599, -2),
ILSimDec(649, -2),
ILSimDec(699, -2),
ILSimDec(749, -2),
ILSimDec(799, -2),
ILSimDec(899, -2),
ILSimDec(949, -2),
ILSimDec(999, -2),
ILSimDec(1099, -2),
ILSimDec(1149, -2),
ILSimDec(1199, -2),
ILSimDec(1249, -2),
ILSimDec(1299, -2),
ILSimDec(1399, -2),
ILSimDec(1449, -2),
ILSimDec(1499, -2),
ILSimDec(1549, -2),
ILSimDec(1599, -2),
ILSimDec(1699, -2),
ILSimDec(1749, -2),
ILSimDec(1799, -2),
ILSimDec(1849, -2),
ILSimDec(1899, -2),
ILSimDec(1999, -2),
ILSimDec(2049, -2),
ILSimDec(2099, -2),
ILSimDec(2149, -2),
ILSimDec(2199, -2),
ILSimDec(2299, -2),
ILSimDec(2349, -2),
ILSimDec(2399, -2),
ILSimDec(2449, -2),
ILSimDec(2499, -2),
ILSimDec(2599, -2),
ILSimDec(2649, -2),
ILSimDec(2699, -2),
ILSimDec(2749, -2),
ILSimDec(2799, -2),
ILSimDec(2899, -2),
ILSimDec(2949, -2),
ILSimDec(2999, -2),
ILSimDec(3299, -2),
ILSimDec(3499, -2),
ILSimDec(3799, -2),
ILSimDec(3999, -2),
ILSimDec(4299, -2),
ILSimDec(4499, -2),
ILSimDec(4999, -2),
ILSimDec(5299, -2),
ILSimDec(5499, -2),
ILSimDec(5999, -2),
ILSimDec(6499, -2),
ILSimDec(6999, -2),
ILSimDec(7499, -2),
ILSimDec(7999, -2),
ILSimDec(8499, -2),
ILSimDec(8999, -2),
ILSimDec(9499, -2),
ILSimDec(9999, -2),
ILSimDec(10999, -2),
ILSimDec(11499, -2),
ILSimDec(11999, -2),
ILSimDec(12499, -2),
ILSimDec(12999, -2),
ILSimDec(13999, -2),
ILSimDec(14999, -2),
ILSimDec(17999, -2),
ILSimDec(19999, -2),
ILSimDec(23999, -2),
ILSimDec(27999, -2),
ILSimDec(29999, -2),
ILSimDec(34999, -2),
ILSimDec(39999, -2),
ILSimDec(44999, -2),
ILSimDec(49999, -2),
ILSimDec(59999, -2),
nil], @"GBP",
[NSArray arrayWithObjects:
ILSimDec(0, 0),
ILSimDec(6, 0),
ILSimDec(11, 0),
ILSimDec(17, 0),
ILSimDec(21, 0),
ILSimDec(29, 0),
ILSimDec(35, 0),
ILSimDec(39, 0),
ILSimDec(45, 0),
ILSimDec(49, 0),
ILSimDec(55, 0),
ILSimDec(59, 0),
ILSimDec(65, 0),
ILSimDec(69, 0),
ILSimDec(75, 0),
ILSimDec(85, 0),
ILSimDec(89, 0),
ILSimDec(95, 0),
ILSimDec(99, 0),
ILSimDec(105, 0),
ILSimDec(109, 0),
ILSimDec(119, 0),
ILSimDec(125, 0),
ILSimDec(129, 0),
ILSimDec(135, 0),
ILSimDec(139, 0),
ILSimDec(145, 0),
ILSimDec(149, 0),
ILSimDec(155, 0),
ILSimDec(159, 0),
ILSimDec(165, 0),
ILSimDec(169, 0),
ILSimDec(175, 0),
ILSimDec(179, 0),
ILSimDec(189, 0),
ILSimDec(195, 0),
ILSimDec(199, 0),
ILSimDec(205, 0),
ILSimDec(209, 0),
ILSimDec(215, 0),
ILSimDec(219, 0),
ILSimDec(225, 0),
ILSimDec(229, 0),
ILSimDec(235, 0),
ILSimDec(239, 0),
ILSimDec(249, 0),
ILSimDec(255, 0),
ILSimDec(259, 0),
ILSimDec(265, 0),
ILSimDec(269, 0),
ILSimDec(279, 0),
ILSimDec(299, 0),
ILSimDec(319, 0),
ILSimDec(349, 0),
ILSimDec(379, 0),
ILSimDec(419, 0),
ILSimDec(439, 0),
ILSimDec(459, 0),
ILSimDec(489, 0),
ILSimDec(519, 0),
ILSimDec(549, 0),
ILSimDec(599, 0),
ILSimDec(619, 0),
ILSimDec(659, 0),
ILSimDec(699, 0),
ILSimDec(769, 0),
ILSimDec(839, 0),
ILSimDec(869, 0),
ILSimDec(899, 0),
ILSimDec(999, 0),
ILSimDec(1049, 0),
ILSimDec(1099, 0),
ILSimDec(1199, 0),
ILSimDec(1249, 0),
ILSimDec(1299, 0),
ILSimDec(1399, 0),
ILSimDec(1699, 0),
ILSimDec(1999, 0),
ILSimDec(2299, 0),
ILSimDec(2499, 0),
ILSimDec(2799, 0),
ILSimDec(3299, 0),
ILSimDec(3899, 0),
ILSimDec(4399, 0),
ILSimDec(4999, 0),
ILSimDec(5499, 0),
nil], @"NOK",

		  
		 nil];
	
	return prices;
}

NSDecimalNumber* ILSimSKPriceAtTierForCurrentStorefront(NSUInteger index) {
	
	NSString* s = ILSimSKCurrentStorefront();
	
	if (index == 0)
		return [NSDecimalNumber zero];

	return [[ILSimSKAllTierPricesByStorefront() objectForKey:s] objectAtIndex:index];
}

NSLocale* ILSimSKLocaleForCurrentStorefront() {
	NSString* l = nil, * s = ILSimSKCurrentStorefront();
	
	if ([s isEqual:@"EUR"])
	l = @"it_IT";
else if ([s isEqual:@"NZD"])
	l = @"en_NZ";
else if ([s isEqual:@"DKK"])
	l = @"da_DK";
else if ([s isEqual:@"AUD"])
	l = @"en_AU";
else if ([s isEqual:@"MXP"])
	l = @"es_MX";
else if ([s isEqual:@"CAD"])
	l = @"en_CA";
else if ([s isEqual:@"USD"])
	l = @"en_US";
else if ([s isEqual:@"JPY"])
	l = @"ja_JP";
else if ([s isEqual:@"GBP"])
	l = @"en_UK";
else if ([s isEqual:@"NOK"])
	l = @"no_NO";

	
	NSCAssert(l, @"Unknown storefront");
	return [[[NSLocale alloc] initWithLocaleIdentifier:l] autorelease];
}

#endif // #if kILSimAllowSimulatedStoreKit