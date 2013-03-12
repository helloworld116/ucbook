//
//  AddCommentViewController.h
//  UCBook
//
//  Created by apple on 13-1-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *content;
@property (nonatomic,copy) NSString *bookId;

-(void)publishComment;
@end
