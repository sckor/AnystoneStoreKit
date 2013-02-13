//
//  ASTStoreViewControllerCommon.c
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-28.
//
//  ASTStoreViewControllerCommon.h
//  ASTStoreKit
//
//  Created by Sean Kormilo on 11-06-28.
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

#include "ASTStoreViewControllerCommon.h"

void updateCellBackgrounds(UITableViewCell* cell, NSIndexPath *indexPath, UIColor *cellBackgroundColor1, UIColor *cellBackgroundColor2)
{
    UIView *backgroundView = cell.backgroundView;
    
    if((indexPath.row % 2) == 0 )
    {
        backgroundView.backgroundColor = cellBackgroundColor1;
    }
    else
    {
        backgroundView.backgroundColor = cellBackgroundColor2;
    }
    
    
    if(( backgroundView.frame.size.height != 0.0 ) &&
       ( backgroundView.frame.size.width != 0.0 ))
    {
        UIView *topLineView = [backgroundView viewWithTag:ASTStoreViewControllerTableViewCellTagTopLineView];
        UIView *bottomLineView = [backgroundView viewWithTag:ASTStoreViewControllerTableViewCellTagBottomLineView];
        
        if( nil == topLineView )
        {   
            CGRect frame = backgroundView.frame;
            frame.size.height = 1;
            
            topLineView = [[[UIView alloc] initWithFrame:frame] autorelease];
            topLineView.tag = ASTStoreViewControllerTableViewCellTagTopLineView;
            topLineView.backgroundColor = [UIColor whiteColor];
            
            topLineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleWidth;
            
            [backgroundView addSubview:topLineView];
        }
        
        if( nil == bottomLineView )
        {   
            CGRect frame = backgroundView.frame;
            frame.origin.y = frame.size.height - 1.0;
            frame.size.height = 1.0;
            
            bottomLineView = [[[UIView alloc] initWithFrame:frame] autorelease];
            bottomLineView.tag = ASTStoreViewControllerTableViewCellTagBottomLineView;
            bottomLineView.backgroundColor = [UIColor blackColor];
            
            bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleWidth;
            
            [backgroundView addSubview:bottomLineView];
        }
        
        topLineView.alpha = 0.3;
        bottomLineView.alpha = 0.3;
        
        if( indexPath.row == 0 )
        {
            topLineView.alpha = 0.0;
        }
    }
}


void setLabelForExpiresDate(NSDate *expiresDate, UILabel *expiresLabel, int isPurchased)
{
    NSString *expiryDateAsString = [NSDateFormatter localizedStringFromDate:expiresDate 
                                                                  dateStyle:NSDateFormatterMediumStyle 
                                                                  timeStyle:NSDateFormatterShortStyle];
    NSString *expiresString = nil;
    
    expiresLabel.textColor = [UIColor blackColor];
    
    if( nil == expiryDateAsString )
    {
        expiresLabel.text = NSLocalizedString(@"Not Subscribed", nil);
        return;
    }
    
    if( isPurchased )
    {
        expiresString = NSLocalizedString(@"Expires: ", nil);
    }
    else
    {
        expiresLabel.textColor = [UIColor redColor];
        expiresString = NSLocalizedString(@"Expired: ", nil);
    }
    
    expiresLabel.text = [NSString stringWithFormat:@"%@%@", expiresString, expiryDateAsString];
}
