//
//  AddCommentViewController.m
//  UCBook
//
//  Created by apple on 13-1-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AddCommentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDictionary+JSONCategories.h"
#import "BookDetailViewController.h"
#import "Toast.h"
#import "NSDictionary+JSONCategories.h"
#import "SVProgressHUD.h"

@interface AddCommentViewController ()<UITextViewDelegate>
@end

@implementation AddCommentViewController
@synthesize content=_content;
@synthesize bookId=_bookId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.content.layer.masksToBounds = YES;
    self.content.layer.borderWidth = 1.0;
    self.content.layer.cornerRadius = 8;
    self.content.layer.borderColor = [[UIColor grayColor] CGColor];
    self.content.delegate=self;
}

- (void)viewDidUnload
{
    [self setContent:nil];
    [self setBookId:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)publishComment{
    [self.content resignFirstResponder];
    NSString *content = self.content.text;
    //1显示状态
    [SVProgressHUD showWithStatus:@"正在保存..."];
    //2从系统中获取一个并行队列
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3在后台线程创建图像选择器
    dispatch_async(concurrentQueue, ^{
        NSDictionary *result = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfAddBookComments];
        //4让主线程显示图像选择器
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if ([[result objectForKey:@"status"] intValue]==1) {
                [Toast showWithText:@"评论添加成功！" bottomOffset:20 duration:1];
                //添加成功
                BookDetailViewController *bookDetailViewController = (BookDetailViewController *)[[self.navigationController viewControllers] objectAtIndex:1];
                bookDetailViewController.tableViewComment.isRefreshing = YES;
                [bookDetailViewController.tableViewComment doneLoadingTableViewData];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [Toast showWithText:@"评论添加失败！" bottomOffset:20 duration:3];
            }
        });
    });
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return NO;
//}

-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
