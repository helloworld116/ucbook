//
//  UserInfoViewController.m
//  UCBook
//
//  Created by apple on 13-1-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UserInfoViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController
//@synthesize lblEmail=_lblEmail;
//@synthesize lblUsername=_lblUsername;

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
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.22 blue:0.15 alpha:1];
    UIBarButtonItem *loginoutItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(loginout)];
    self.navigationItem.rightBarButtonItem = loginoutItem;
    
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    UILabel *lblPersonInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 35)];
//    lblPersonInfo.text = @"个人资料";
//    lblPersonInfo.textAlignment = UITextAlignmentCenter;
//    UILabel *lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 280, 35)];
//    lblPersonInfo.text = @"昵称";
//    self.lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 280, 35)];
//    UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 280, 35)];
//    lblPersonInfo.text = @"邮箱";
//    self.lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 35)];
//
//    [contentView addSubview:lblPersonInfo];
//    [contentView addSubview:lblUsername];
//    [contentView addSubview:self.lblUsername];
//    [contentView addSubview:lblEmail];
//    [contentView addSubview:self.lblEmail];
//    
//    [self.view addSubview:contentView];
}

-(void)loginout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"email"];
    [defaults removeObjectForKey:@"password"];
    LoginViewController *loginViewController = (LoginViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:loginViewController action:@selector(back)];
//    loginViewController.navigationItem.leftBarButtonItem = backItem;
    loginViewController.navigationItem.hidesBackButton = YES;
    SharedApp.uid=nil;
    SharedApp.email=nil;
    SharedApp.username=nil;
    SharedApp.ticket=nil;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)viewDidUnload
{
//    [self setLblUsername:nil];
//    [self setLblEmail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
