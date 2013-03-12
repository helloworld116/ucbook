//
//  AppDelegate.h
//  UCBook
//
//  Created by apple on 12-12-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#define SharedApp ((AppDelegate *)[[UIApplication sharedApplication] delegate])
//下载保存的根目录
#define kDownloadRootPath @"Documents"
//书籍保存路径
#define KBookSavePath @"ucbook"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *ticket;

@property (nonatomic,readwrite) BOOL isPaySuccess;

@property (nonatomic,retain) UITabBarController *tabBarController;

@end
