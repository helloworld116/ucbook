//
//  SqlUtils.h
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "sqlite3.h"

@interface SqlUtils : NSObject
@property (nonatomic) sqlite3 *database;
//创建表
-(BOOL)createTable;

#pragma mark 书籍
//查询本地所有的书籍id
-(NSArray *)getLocalBookIds;

//查询本地所有的书籍列表
-(NSArray*)getLocalBooks;

//添加本地书籍
-(BOOL)addLocalBook:(NSDictionary *)book;

//根据书籍id移除本地书籍
-(BOOL)removeLocalBook:(int) bid;

#pragma mark 章节
//添加章节
-(BOOL)addChapter:(NSInteger)bookId chapters:(NSArray *)chapters rootPath:(NSString *)rootPath;

//查询书籍所有章节信息
-(NSArray *)getBookChaptersByBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId;

//根据书籍id移除章节信息
-(BOOL)removeChapterByBookId:(NSInteger)bookId;

#pragma mark 书签
//书签是否已添加
-(BOOL)isBookmarkExist:(NSDictionary *)bookmark;

//添加书签
-(BOOL)addBookmark:(NSDictionary *)bookmark;

//根据书籍id查询改书籍保存在本地的书签
-(NSArray *)getBookmarksByBookId:(int) bid chapterId:(NSUInteger)chapterId;

//根据书籍id移除书签
-(BOOL)removeBookmark:(NSDictionary *) bookmark;

//根据书籍id移除书签
-(BOOL)removeBookmarkByBookId:(NSInteger) bookId;
@end
