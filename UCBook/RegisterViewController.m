//
//  RegisterViewController.m
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "NSDictionary+JSONCategories.h"
#import "Toast.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "UserInfoViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (nonatomic,copy) NSString* username;
@property (nonatomic,copy) NSString* password;
@property (nonatomic,copy) NSString* email;
@end

@implementation RegisterViewController
@synthesize txtUsername=_txtUsername;
@synthesize txtPassword=_txtPassword;
@synthesize txtEmail=_txtEmail;
@synthesize txtPassword2 = _txtPassword2;
@synthesize username=_username;
@synthesize password=_password;
@synthesize email=_email;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.txtUsername.delegate = self;
    self.txtPassword.delegate = self;
    self.txtEmail.delegate = self;
    self.txtPassword2.delegate = self;
    self.txtPassword2.secureTextEntry = YES;
    self.txtPassword.secureTextEntry = YES;//uitextfield以密码的方式显示
}

- (void)viewDidUnload
{
    [self setTxtUsername:nil];
    [self setTxtPassword:nil];
    [self setTxtEmail:nil];
    [self setTxtPassword2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}


- (IBAction)register:(id)sender {
    if(![self checkRegisterField]){
        return;
    }
    //1显示状态
    [SVProgressHUD showWithStatus:@"正在注册..."];
    //2从系统中获取一个并行队列
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3在后台线程创建图像选择器
    dispatch_async(concurrentQueue, ^{
        NSDictionary *result = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfRegister];
        //4让主线程显示图像选择器
        dispatch_async(dispatch_get_main_queue(), ^{
            if([@"success" isEqualToString:[result objectForKey:@"status"]]){
                NSDictionary *loginResult = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfLogin];
                if (1==[[loginResult objectForKey:@"status"] intValue]) {
                    NSLog(@"登录成功");
                    [SVProgressHUD dismissWithSuccess:@"注册成功"];
                    SharedApp.uid = [loginResult objectForKey:@"uid"];
                    SharedApp.username = [loginResult objectForKey:@"uname"];
                    SharedApp.email = [loginResult objectForKey:@"email"];
                    SharedApp.ticket = [loginResult objectForKey:@"ticket"];
                    //保存到NSUserDefaults
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.email forKey:@"email"];
                    [defaults setObject:self.password forKey:@"password"];
                    NSUInteger tabSelectIndex = SharedApp.tabBarController.selectedIndex;
                    UserInfoViewController *userInfoViewController = (UserInfoViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"userInfoViewController"];
                    userInfoViewController.navigationItem.hidesBackButton = YES;
                    userInfoViewController.title = @"我";
                    UILabel *lableUsername = (UILabel *)[[userInfoViewController.view subviews] objectAtIndex:2];
                    lableUsername.text = SharedApp.username;
                    UILabel *lableEmail = (UILabel *)[[userInfoViewController.view subviews] objectAtIndex:4];
                    lableEmail.text = SharedApp.email;
                    if (tabSelectIndex==2) {
                        [self.navigationController pushViewController:userInfoViewController animated:YES];
                    }else {
                        UINavigationController *navigationController = (UINavigationController *)[[SharedApp.tabBarController viewControllers]objectAtIndex:2];
                        [navigationController pushViewController:userInfoViewController animated:NO];
                        //跳转
                        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
                    }
                }else {
                    NSString *desc = [loginResult objectForKey:@"description"];
                    NSLog(@"%@",desc);
                    [SVProgressHUD dismissWithSuccess:@"注册成功，登录失败，请自行登录"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                //清空数据
                self.txtUsername.text=nil;
                self.txtPassword.text=nil;
                self.txtPassword2.text=nil;
                self.txtEmail.text=nil;
            }else {
                NSString *desc = [result objectForKey:@"description"];
                [SVProgressHUD dismissWithSuccess:desc];
                //注册失败只清空密码
                self.txtPassword.text = nil;
                self.txtPassword2.text = nil;
            }
        });
    });
}

- (BOOL) checkRegisterField{
    //todo
    self.username = self.txtUsername.text;
    self.password = self.txtPassword.text;
    self.email = self.txtEmail.text;
    if (![CommonUtils isEmailAddress:self.email]) {
        [Toast showWithText:@"请输入正确的邮箱地址" bottomOffset:60 duration:3];
//        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (![self.password isEqualToString:self.txtPassword2.text]) {
        [Toast showWithText:@"两次输入的密码不一致" bottomOffset:60 duration:3];
        self.txtPassword.text=nil;
        self.txtPassword2.text=nil;
        return NO;
    }
    
    return YES;
}
@end
