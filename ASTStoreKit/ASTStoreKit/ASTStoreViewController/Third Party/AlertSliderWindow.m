//
//  AlertModalWindow.m
//
//  Created by Gregory Meach on 10-05-08.
//  http://meachware.com

//  Copyright (c) 2010 Gregory Meach, MeachWare.
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

#import "AlertSliderWindow.h"

// set to 0: disable
// set to 1: enabled, add custom images for slider
#define USE_CUSTOM_SLIDER   0

@implementation AlertSliderWindow

@synthesize pressedButton, sliderValue, alertLabel, alertSlider;

+(void)initialize {
	[super initialize];
}

- (void)sliderAction:(UISlider*)sender {
	self.alertLabel.text = [NSString stringWithFormat:@"Selected Amount: %i", (int)[sender value]];
}


- (id)initWithTitle:(NSString *)title yoffset:(int)yoffset setValue:(int)setValue minValue:(int)minValue maxValue:(int)maxValue message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle 
{
	[self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
	
	self.alertSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, yoffset+100, 220, 50)];
	self.alertSlider.minimumValue = (float)minValue;
	self.alertSlider.maximumValue = (float)maxValue;
	self.alertSlider.value = (float)setValue;
	self.alertSlider.continuous = YES;

	[alertSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    if (USE_CUSTOM_SLIDER) {
        // Setup custom slider images
        UIImage *minImage = [UIImage imageNamed:@"leftSide.png"];
        UIImage *maxImage = [UIImage imageNamed:@"rightSide.png"];
        UIImage *thumbImage = [UIImage imageNamed:@"thumb.png"];
        UIImage *thumbPressedImage = [UIImage imageNamed:@"thumbpressed.png"];
        
        minImage=[minImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        maxImage=[maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        
        // Setup the sliders
        [alertSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [alertSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [alertSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [alertSlider setThumbImage:thumbPressedImage forState:UIControlEventTouchDown];
    }

	self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yoffset+88, 240, 22)];
	self.alertLabel.backgroundColor = [UIColor clearColor];
	self.alertLabel.textColor = [UIColor whiteColor];
	self.alertLabel.font = [UIFont systemFontOfSize:16];
	self.alertLabel.textAlignment = UITextAlignmentCenter;
	self.alertLabel.text = [NSString stringWithFormat:@"Selected Amount: %i", setValue];

	[self addSubview: alertSlider];
	[self addSubview: alertLabel];

	[alertLabel release];
	[alertSlider release];
		
	return self;
}

-(void)dealloc {
	[super dealloc];
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	pressedButton = buttonIndex;
}


@end
