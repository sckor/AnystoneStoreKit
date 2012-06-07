//
//  UIView+SimpleLayerGradient.m
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-24.
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

#import "UIView+SimpleLayerGradient.h"

#define kUIViewEnhancementsGradientName @"UIViewEnhancementGradient"

@implementation UIView (SimpleLayerGradient)
- (void)setSimpleLayerGradient:(UIColor*)startColor endColor:(UIColor*)endColor
{
    NSArray *colors = [NSArray arrayWithObjects:(id)[startColor CGColor],(id)[endColor CGColor], nil];
    [self setLayerGradient:colors];
}

// Found from here:
// http://stackoverflow.com/questions/422066/gradients-on-uiview-and-uilabels-on-iphone

- (CAGradientLayer*)gradientLayerFromColorArray:(NSArray*)colorArray
{
    CAGradientLayer *aGradientLayer = [CAGradientLayer layer];
    aGradientLayer.frame = self.bounds;
    aGradientLayer.colors = colorArray;
    aGradientLayer.name = kUIViewEnhancementsGradientName;
    
    return aGradientLayer;
}

- (void)setLayerGradient:(NSArray*)colorArray
{
    CAGradientLayer *aGradientLayer = [self gradientLayerFromColorArray:colorArray];    
    CAGradientLayer *existingGradientLayer = nil;
    
    for( CALayer *aLayer in self.layer.sublayers )
    {
        if( NSOrderedSame == [aLayer.name compare:kUIViewEnhancementsGradientName] )
        {
            existingGradientLayer = (CAGradientLayer*) aLayer;
            break;
        }
    }
    
    if( nil != existingGradientLayer )
    {
        [existingGradientLayer removeFromSuperlayer];
    }
    
    self.layer.masksToBounds = YES;
    
    [self.layer insertSublayer:aGradientLayer atIndex:0];
}

- (void)setLayerGradientCornerRadius:(CGFloat)radius
{
    CAGradientLayer *existingGradientLayer = nil;
    
    for( CALayer *aLayer in self.layer.sublayers )
    {
        if( NSOrderedSame == [aLayer.name compare:kUIViewEnhancementsGradientName] )
        {
            existingGradientLayer = (CAGradientLayer*) aLayer;
            break;
        }
    }
    
    if( nil == existingGradientLayer )
    {
        return;
    }
    
    existingGradientLayer.cornerRadius = radius;
}

@end
