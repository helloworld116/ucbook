//
//  MyUtils.h
//  UCBook
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+(NSString *)getBookStatus:(NSString *)status;

+(NSString *)timestampToTime:(NSString *) timestamp format:(NSString *) format;

//返回YYYY-MM-DD HH:MM:SS格式的当前时间
+(NSString *)getCurrentTime;

//获取下载时需要使用到的key
+(NSString *)getDownloadKey;

//检查是否是邮箱地址
+(BOOL)isEmailAddress:(NSString*)email;

//根据系统价格调整为苹果需要设定的价格
+(NSString *)showPrice:(NSString *)price;

//根据书籍价格获得IAP中的productid
+(NSString *)getIAPProductId:(NSString *)price;
@end
