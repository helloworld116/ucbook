//
//  LoginViewController.m
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "NSDictionary+JSONCategories.h"
#import "Toast.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "UserInfoViewController.h"
#import "SVProgressHUD.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *password;
@end

@implementation LoginViewController
@synthesize txtUsername=_txtUsername;
@synthesize txtPassword=_txtPassword;
@synthesize email=_email;
@synthesize password=_password;

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
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.22 blue:0.15 alpha:1];
    UIBarButtonItem *registItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(goRegistPage)];
    self.navigationItem.rightBarButtonItem = registItem;
    
    self.txtUsername.delegate = self;
    self.txtPassword.delegate = self;
    self.txtPassword.secureTextEntry = YES;//uitextfield以密码的方式显示
}

-(void)goRegistPage{
    RegisterViewController *registerViewController = (RegisterViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"registerViewController"];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setTxtUsername:nil];
    [self setTxtPassword:nil];
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

- (IBAction)login:(id)sender {
    [self textFieldShouldReturn:self.txtUsername];
    [self textFieldShouldReturn:self.txtUsername];
    if (![self checkLoginField]) {
        return;
    } 
    //1显示状态
    [SVProgressHUD showWithStatus:@"正在登录..."];
    //2从系统中获取一个并行队列
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3在后台线程创建图像选择器
    dispatch_async(concurrentQueue, ^{
        NSDictionary *result = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfLogin];
        //4让主线程显示图像选择器
        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
            if (1==[[result objectForKey:@"status"] intValue]) {
                [SVProgressHUD dismissWithSuccess:@"登录成功！"];
//                [Toast showWithText:@"登录成功！" bottomOffset:60 duration:1];
                SharedApp.uid = [result objectForKey:@"uid"];
                SharedApp.username = [result objectForKey:@"uname"];
                SharedApp.email = [result objectForKey:@"email"];
                SharedApp.ticket = [result objectForKey:@"ticket"];
                //清空显示
                self.txtUsername.text=nil;
                self.txtPassword.text=nil;
                //保存到NSUserDefaults
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.email forKey:@"email"];
                [defaults setObject:self.password forKey:@"password"];
                NSUInteger tabSelectIndex = SharedApp.tabBarController.selectedIndex;
                UserInfoViewController *userInfoViewController = (UserInfoViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"userInfoViewController"];
                userInfoViewController.navigationItem.hidesBackButton = YES;
                userInfoViewController.title = @"我";
                //            userInfoViewController.lblUsername.text = SharedApp.username;
                //            userInfoViewController.lblEmail.text = SharedApp.email;
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
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else {
                NSString *errorMessage = [result objectForKey:@"description"];
                [SVProgressHUD dismissWithError:errorMessage];
//                [Toast showWithText:errorMessage bottomOffset:80 duration:30];
                //登录失败只清空密码
                self.txtPassword.text = nil;
            }
        });
    });
}

-(BOOL) checkLoginField{
    self.email = self.txtUsername.text;
    self.password = self.txtPassword.text;
    return YES;
}
@end
