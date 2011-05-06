//
//  ASTRootViewController.h
//  ASTStore
//
//  Created by Greg Meach on 5/6/11.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTStoreViewController.h"



@interface ASTRootViewController : UIViewController <ASTStoreViewControllerDelegate> {
 
    BOOL isAniPad;

}

- (IBAction)showASTStoreBtnPressed:(id)sender;

@end
