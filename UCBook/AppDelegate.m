//
//  AppDelegate.m
//  UCBook
//
//  Created by apple on 12-12-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SqlUtils.h"
#import "NSDictionary+JSONCategories.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "AlixPay.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import <sys/utsname.h>

@interface AppDelegate()
@property (nonatomic,copy) NSString *password;

- (BOOL)isSingleTask;
- (void)parseURL:(NSURL *)url application:(UIApplication *)application;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize ticket=_ticket;
@synthesize uid=_uid;
@synthesize email=_email;
@synthesize username=_username;
@synthesize password=_password;
@synthesize tabBarController=_tabBarController;
@synthesize isPaySuccess=_isPaySuccess;

- (BOOL)isSingleTask{
	struct utsname name;
	uname(&name);
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
		return YES;
	}
	else {
		return NO;
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *file = [path stringByAppendingPathComponent:@"data.rdb"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:file]==FALSE) {
//        NSString *fromFile = [[NSBundle mainBundle] pathForResource:@"data.rdb" ofType:nil];
//        [[NSFileManager defaultManager] copyItemAtPath:fromFile toPath:file error:nil];
//    }
//    if (sqlite3_open([file UTF8String], &_database)!=SQLITE_OK) {
//        NSAssert1(0, @"failed to open database with message '%s'.", sqlite3_errmsg(_database));
//    }
    self.tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *mineNavigationController = (UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:2];
//    BOOL loginState = NO;
    BOOL loginState = [self backstageLogin];
    if (loginState) {
        UserInfoViewController *userInfoViewController = (UserInfoViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"userInfoViewController"];
        
//        UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
        userInfoViewController.title = @"我";
        UILabel *lableUsername = (UILabel *)[[userInfoViewController.view subviews] objectAtIndex:2];
        lableUsername.text = self.username;
        UILabel *lableEmail = (UILabel *)[[userInfoViewController.view subviews] objectAtIndex:4];
        lableEmail.text = self.email;
        [mineNavigationController pushViewController:userInfoViewController animated:NO];
        [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(backstageLogin) userInfo:nil repeats:YES];
    }else {
        LoginViewController *loginViewController = (LoginViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [mineNavigationController pushViewController:loginViewController animated:NO];
    }
    SqlUtils *sqlUtils = [[SqlUtils alloc] init];
    [sqlUtils createTable];
    
    /*
	 *单任务handleURL处理
	 */
	if ([self isSingleTask]) {
		NSURL *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
		
		if (nil != url) {
			[self parseURL:url application:application];
		}
	}
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"url is %@",url);
	[self parseURL:url application:application];
	return YES;
}


- (void)parseURL:(NSURL *)url application:(UIApplication *)application {
	AlixPay *alixpay = [AlixPay shared];
	AlixPayResult *result = [alixpay handleOpenURL:url];
	if (result) {
		//是否支付成功
		if (9000 == result.statusCode) {
			/*
			 *用公钥验证签名
			 */
			id<DataVerifier> verifier = CreateRSADataVerifier([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA public key"]);
			if ([verifier verifyString:result.resultString withSign:result.signString]) {
                self.isPaySuccess = YES;
                NSLog(@"result.statusMessage is %@",result.statusMessage);
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																	 message:@"支付成功,请重新点击下载" 
																	delegate:nil 
														   cancelButtonTitle:@"确定" 
														   otherButtonTitles:nil];
				[alertView show];
			}//验签错误
			else {
                self.isPaySuccess = NO;
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																	 message:@"签名错误" 
																	delegate:nil 
														   cancelButtonTitle:@"确定" 
														   otherButtonTitles:nil];
				[alertView show];
			}
		}
		//如果支付失败,可以通过result.statusCode查询错误码
		else {
            self.isPaySuccess = NO;
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																 message:result.statusMessage 
																delegate:nil 
													   cancelButtonTitle:@"确定" 
													   otherButtonTitles:nil];
			[alertView show];
		}
		
	}	
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//-(NSString *)ticket{
////    http://t.ucai.com/index.php?app=home&mod=Public&act=login_p&email=904919222@qq.com&password=123456
//    return @"8e27016e1332938500324002092143-aGVsbw==";
//}

//后台检查登录
-(BOOL)backstageLogin{
    //清空登录信息
    self.uid = nil;
    self.username = nil;
    self.email = nil;
    self.ticket = nil;
    self.password = nil;
    //从用户默认数据中获取用户登录信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.email = [defaults objectForKey:@"email"];
    self.password = [defaults objectForKey:@"password"];
    //执行登录操作
    NSDictionary *result = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfLogin];
    if (1==[[result objectForKey:@"status"] intValue]) {
        self.uid = [result objectForKey:@"uid"];
        self.username = [result objectForKey:@"uname"];
        self.email = [result objectForKey:@"email"];
        self.ticket = [result objectForKey:@"ticket"];
        return YES;
    }else {
        return NO;
    }
}

////列出所有已下载的书籍id
//-(NSArray *)allDownloadBooks{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:kDownloadRootPath];
//    NSString *folderpath = [path stringByAppendingPathComponent:KBookSavePath];
//    NSArray *fileList = [[NSArray alloc] init];
//    NSError *error = nil;
//    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
//    fileList = [fileManager contentsOfDirectoryAtPath:folderpath error:&error];
//    return fileList;
//}
////列出本地所有的书籍图片路径
////列出所有已下载的书籍id
//-(NSArray *)allDownloadBookImages{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *folderpath = [[[NSHomeDirectory() stringByAppendingPathComponent:kDownloadRootPath] stringByAppendingPathComponent:KBookSavePath] stringByAppendingPathComponent:@"images"];
//    NSArray *fileList = [[NSArray alloc] init];
//    NSError *error = nil;
//    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
//    fileList = [fileManager contentsOfDirectoryAtPath:folderpath error:&error];
//    return fileList;
//}
@end
