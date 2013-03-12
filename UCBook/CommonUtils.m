//
//  MyUtils.m
//  UCBook
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "CommonUtils.h"
#import "NSDictionary+JSONCategories.h"
#import "Toast.h"

#define ProductID_IAP6 @"com.jdtx.book.price_6" //￥6
#define ProductID_IAP12 @"com.jdtx.book.price_12" //￥12
#define ProductID_IAP18 @"com.jdtx.book.price_18" //￥18

@implementation CommonUtils
+(NSString *)getBookStatus:(NSString *)status{
    NSString *result;
    switch ([status intValue]) {
        case 0:
            result = @"已完结";
            break;
        case 1:
            result = @"连载中";
            break;
        default:
            result = @"已完结";
            break;
    }
    return result;
}

+(NSString *)timestampToTime:(NSString *) timestamp format:(NSString *) format{
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]]];
}

//返回YYYY-MM-DD HH:MM:SS格式的当前时间
+(NSString *)getCurrentTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

//获取下载时需要使用到的key
+(NSString *)getDownloadKey{
    NSDictionary *keyInfo = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfDownloadKey];
    if ([[keyInfo objectForKey:@"status"] intValue]==1) {
        return [keyInfo objectForKey:@"dataInfo"];
    }else {
        NSLog(@"获取下载key失败");
        [Toast showWithText:@"获取下载key失败" bottomOffset:80 duration:5];
        return nil;
    }
}

//检查是否是邮箱地址
+ (BOOL)isEmailAddress:(NSString*)email { 
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:email]; 
    
}

+(NSString *)showPrice:(NSString *)price{
    int beginPrice = [price intValue];
    if (beginPrice==0) {
        return @"0.00";
    }else if(beginPrice<=6){
        return @"6.00";
    }else if(beginPrice<=12){
        return @"12.00";
    }else if(12.00<beginPrice){    
        return @"18.00";
    }else{
        return @"0.00";
    }
}

+(NSString *)getIAPProductId:(NSString *)price{
    double beginPrice = [price doubleValue];
    if(beginPrice<=6.00){
        return ProductID_IAP6;
    }else if(beginPrice<=12.00){
        return ProductID_IAP12;
    }else if(12.00<beginPrice){
        return ProductID_IAP18;
    }else{
        return ProductID_IAP6;
    }
}
@end
