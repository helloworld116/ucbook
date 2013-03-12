//
//  NSDictionary+JSONCategories.h
//  ShopCloth
//
//  Created by apple on 12-12-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//外网
#define kUrlOfInitServices @"http://shopmgr.ucai.com/index.php?uf=pub&um=initShop&key=ucai2012&imsi=1&phone_num=1&app_name=%E5%A5%B3%E8%A3%85&app=shop_clothes&uccode=ucai"
#define kUrlOfBase @"http://cartoon.ucai.com/pub.php?code="
#define kShopCode @"12123110"
//版本信息
#define kUrlVersion @"http://app.ucai.com/upload/version/ucshop.html"
//用户注册登录
#define kUrlOfMember @"http://t.ucai.com"


//内网
//#define kUrlOfInitServices @"http://192.168.1.188/shopmgrdev/index.php?uf=pub&um=initShop&key=ucai2012&imsi=1&phone_num=1&app_name=%E5%A5%B3%E8%A3%85&app=shop_clothes&uccode=ucai"
//#define kUrlOfBase @"http://192.168.1.188/cartoondev/pub.php?code="
//#define kShopCode @"1209062"
////版本信息
//#define kUrlVersion @"http://192.168.1.188/app/version/ucshop.html"
////用户注册登录
//#define kUrlOfMember @"http://192.168.1.188/ucsns"


//注册
#define kUrlOfRegister [kUrlOfMember stringByAppendingFormat:@"%@%@%@%@%@%@",@"/index.php?app=home&mod=Public&act=register_p&username=",self.username,@"&password=",self.password,@"&email=",self.email]
//登录
#define kUrlOfLogin [kUrlOfMember stringByAppendingFormat:@"%@%@%@%@",@"/index.php?app=home&mod=Public&act=login_p&email=",self.email,@"&password=",self.password]
//#define kShopCode SharedApp.shopcode
#define kDefaultPageSize 10
#define kDefaultCurrentPage 1
//首页新闻
#define kUrlOfIndexNews [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_home_news"]
//店铺相册
#define kUrlOfShopAlbum [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_album_photos"]
//新品
#define kUrlOfNewGoods [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_recommend_goods&type=new"]
//热卖
#define kUrlOfHotGoods [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_recommend_goods&type=hot"]
//推荐
#define kUrlOfRecommendGoods [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_recommend_goods&type=best"]
//品牌
#define kUrlOfBrands [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_brands"]
//商品分类
#define kUrlOfCategories [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_goods_categories"]
//商品详情
#define kUrlOfGoodsDetail [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=get_goods_info&id=",self.goodsId]
//漫画详情
#define kUrlOfBooksDetail [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=getCartooninfo&gid=",self.bookId]
//商品相册
#define kUrlOfGoodsImgs [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=good_pics&gid=",self.goodsId]
//友情链接
#define kUrlOfFriendLink [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_friend_links"]
//新闻列表
#define kUrlOfNews [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=index_get_new_articles"]
//新闻详情,必须在使用页面定义newsId属性
#define kUrlOfNewsDetail [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=get_article_info&id=",self.newsId]
//优惠活动列表
#define kUrlOfActivity [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_promotion_info"]
//优惠活动详情
#define kUrlOfActivityDetail [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=favourable_info&id=",self.activityId]
//案例
#define kUrlOfCase [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_corp_case"]
//案例详情
#define kUrlOfCaseDetail [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=get_article_info&id=",self.caseId]
//根据品牌查询某个品牌下的商品
#define kUrlOfGoodsByBrand [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_goods_by_brandid"]
//根据商品分类查询某个分类下的商品
#define kUrlOfGoodsByCategory [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_category_goods"]
//合作伙伴
#define kUrlOfPartners [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=get_friend_links"]
//关于我们
#define kUrlOfAboutUs [kUrlOfBase stringByAppendingFormat:@"%@%@",kShopCode,@"&act=shop_info"]
//下载key
#define kUrlOfDownloadKey [kUrlOfBase stringByAppendingFormat:@"%@%@%@",kShopCode,@"&act=get_downkey&ticket=",SharedApp.ticket]
//整本书下载路径
#define kUrlOfBookDownloadPath [kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%@%@%@",kShopCode,@"&act=down_book&gid=",self.bookId,@"&ticket=",SharedApp.ticket,@"&key=",self.key]
//某章节下载路径
#define kUrlOfCharacterDownloadPath [kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%@%@%@",kShopCode,@"&act=down_chapter&cid=",self.characterId,@"&ticket=",SharedApp.ticket,@"&key=",self.key]
//某书籍的章节路径
#define kUrlOfChapterPath [kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%@%@%@",kShopCode,@"&act=getpicinfobygid&gid=",self.bookId,@"&ticket=",SharedApp.ticket,@"&key=",self.key]
//章节获取章节下的书籍路径
#define kUrlOfFilePathByChapterId [kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%@%@%@",kShopCode,@"&act=getpicinfobychid&cid=",chapterId,@"&ticket=",SharedApp.ticket,@"&key=",self.key]
//书籍评论列表
#define kUrlOfBookComments [kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%i%@%i",kShopCode,@"&act=getComment&gid=",self.bookId,@"&currentPage=",self.currentPage,@"&pageSize=",kDefaultPageSize]
//添加书籍评论
#define kUrlOfAddBookComments [[kUrlOfBase stringByAppendingFormat:@"%@%@%@%@%@%@%@",kShopCode,@"&act=addComment&gid=",self.bookId,@"&ticket=",SharedApp.ticket,@"&comment=",content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]

@interface NSDictionary (JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end
