//
//  SqlUtils.m
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SqlUtils.h"
#import "CommonUtils.h"

@implementation SqlUtils
@synthesize database=_database;

-(void)execSql:(const char *)sql{
    //    AppDelegate.database;
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(self.database, sql, -1, &stmt, NULL);
    //    sqlite3_bind_text(stmt, 1, <#const char *#>, <#int n#>, <#void (*)(void *)#>)
    //提交sql
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

-(id)init{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask 
                                                                , YES); 
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"ucbook.db"];
//    NSString *databaseFilePath = [[NSBundle mainBundle] pathForResource:@"ucbook.db" ofType:nil];
    if (sqlite3_open([databaseFilePath UTF8String], &_database)==SQLITE_OK) { 
//        NSLog(@"open sqlite db ok."); 
    }else {
        NSLog(@"open sqlite db error");
    }
    return self;
}

-(BOOL)createTable{
    char *errorMsg;
    const char *createLoaclBookSql = "create table if not exists localbook(id integer primary key autoincrement,bookId integer not null,coverUri text,isdelete integer,addTime datetime)";
    const char *createChapterSql = "create table if not exists bookchapter(id integer primary key autoincrement,bookId integer not null,chapterId integer,fileUri text,isdelete integer,addTime datetime)";
    const char *createBookmarkSql = "create table if not exists bookmark(id integer primary key autoincrement,bookId integer not null,chapterId integer,markname text,page integer,isdelete integer,addTime datetime)";
    const char *createReadHistorySql = "create table if not exists readhistory(id integer primary key autoincrement,bookId integer not null,page integer,addTime datetime)";
    if ((sqlite3_exec(self.database, createLoaclBookSql, NULL, NULL, &errorMsg)==SQLITE_OK)&&(sqlite3_exec(self.database, createBookmarkSql, NULL, NULL, &errorMsg)==SQLITE_OK)&&(sqlite3_exec(self.database, createReadHistorySql, NULL, NULL, &errorMsg)==SQLITE_OK)&&
        (sqlite3_exec(self.database, createChapterSql, NULL, NULL, &errorMsg)==SQLITE_OK)) {
        NSLog(@"create table success");
        return YES;
    }else {
        NSLog(@"create table error,the detail message is %s",errorMsg);
        sqlite3_free(errorMsg); 
        return NO;
    }
}
//添加本地书籍
-(BOOL)addLocalBook:(NSDictionary *)book{
    BOOL result = NO;
    const char *insertSql = "insert into localbook(bookId,coverUri,isdelete,addTime) values(?,?,?,?)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, insertSql, -1, &stmt, nil)==SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, [[book objectForKey:@"bookId"] intValue]);
        sqlite3_bind_text(stmt, 2, [[book objectForKey:@"coverUri"] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 3, 0);
        sqlite3_bind_text(stmt, 4, [[CommonUtils getCurrentTime] UTF8String], -1, NULL);
        if(sqlite3_step(stmt)!=SQLITE_DONE){
            NSLog(@"添加本地书籍出错");
        }else {
            NSLog(@"添加本地书籍到数据库成功");
            result = YES;
        }
        sqlite3_finalize(stmt);
    }
    return result;
}
//添加章节
-(BOOL)addChapter:(NSInteger)bookId chapters:(NSArray *)chapters rootPath:(NSString *)rootPath{
    const char *insertSql = "insert into bookchapter(bookId,chapterId,fileUri,isdelete,addTime) values(?,?,?,?,?)";
    sqlite3_stmt *stmt;
    int count=0;//记录插入成功的次数
    for (int i=0; i<[chapters count]; i++) {
        NSDictionary *chapter = [chapters objectAtIndex:i];
        if (sqlite3_prepare_v2(self.database, insertSql, -1, &stmt, nil)==SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, bookId);
            sqlite3_bind_int(stmt, 2, [[chapter objectForKey:@"chapter_id"] intValue]);
            sqlite3_bind_text(stmt, 3, [[NSString stringWithFormat:@"%@%@",rootPath,[chapter objectForKey:@"name"]] UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 4, 0);
            sqlite3_bind_text(stmt, 5, [[CommonUtils getCurrentTime] UTF8String], -1, NULL);
            int sqlCode = sqlite3_step(stmt);
            if(sqlCode!=SQLITE_DONE){
                NSLog(@"添加本地书籍章节出错,错误码为:%i",sqlCode);
            }else {
//                NSLog(@"添加本地书籍章节到数据库成功");
                count++;
            }
        }
        sqlite3_finalize(stmt);
    }
    if (count==[chapters count]) {
        NSLog(@"所有章节都已添加");
    }
    return count==[chapters count];
}
//查询书籍所有章节信息
-(NSArray *)getBookChaptersByBookId:(NSInteger)bookId chapterId:(NSInteger)chapterId{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"%@%i",@"select * from bookchapter where isdelete=0 and bookId=",bookId];
    if (chapterId!=0) {
        sql = [sql stringByAppendingFormat:@"%@%i",@" and chapterId=",chapterId];
    }
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSString *_id = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
            NSString *bookId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
            NSString *chapterId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
            NSString *fileUri = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 3)];
            NSString *isdelete = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 4)];
            NSString *addTime = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 5)];
            NSMutableDictionary *chapter = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_id,@"id" ,bookId,@"bookId",chapterId,@"chapterId",fileUri,@"fileUri",isdelete,@"isdelete",addTime,@"addTime",nil];
            [result addObject:chapter];
        }
    }
    sqlite3_finalize(stmt);
    return result;
}

//根据书籍id移除本地书籍
-(BOOL)removeLocalBook:(int) bid{
    BOOL result = NO;
    const char *sql = "update localbook set isdelete=1 where bookId=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil)==SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, bid);
        if (sqlite3_step(stmt)!=SQLITE_DONE) {
            NSLog(@"删除书籍出错");
        }else {
            result = YES;
        }
    }
    return result;
}

//查询本地所有的书籍id
-(NSArray *)getLocalBookIds{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    const char *sql = "select bookId from localbook where isdelete=0";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSString *bookId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
            [result addObject:bookId];
        }
    }
    sqlite3_finalize(stmt);
    return result;
}

//查询本地所有的书籍列表
-(NSArray*)getLocalBooks{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    const char *sql = "select distinct bookid,coveruri from localbook where isdelete=0";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {
//            NSString *_id = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
//            NSString *bookId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
//            NSString *coverUri = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
//            NSString *isdelete = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 3)];
//            NSString *addTime = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 4)];
//            NSMutableDictionary *book = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_id,@"id" ,bookId,@"bookId",coverUri,@"coverUri",isdelete,@"isdelete",addTime,@"addTime",nil];
            NSString *bookId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
            NSString *coverUri = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
            NSMutableDictionary *book = [[NSMutableDictionary alloc] initWithObjectsAndKeys:bookId,@"bookId",coverUri,@"coverUri",nil];
            [result addObject:book];
        }
    }
    sqlite3_finalize(stmt);
    return result;
}
//添加书签
-(BOOL)addBookmark:(NSDictionary *)bookmark{
    BOOL result = NO;
    const char *sql = "insert into bookmark(bookId,chapterId,markname,page,isdelete,addtime) values(?,?,?,?,?,?)";
    sqlite3_stmt *stmt;
    NSLog(@"the code is %i",sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil));
    if (sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil)==SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, [[bookmark objectForKey:@"bookId"] intValue]);
        sqlite3_bind_int(stmt, 2, [[bookmark objectForKey:@"chapterId"] intValue]);
        sqlite3_bind_text(stmt, 3, [[bookmark objectForKey:@"markname"] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, [[bookmark objectForKey:@"page"] intValue]);
        sqlite3_bind_int(stmt, 5, 0);
        sqlite3_bind_text(stmt, 6, [[CommonUtils getCurrentTime] UTF8String], -1, NULL);
        int sqlCode = sqlite3_step(stmt);
        if(sqlCode!=SQLITE_DONE){
            NSLog(@"添加本地书籍章节出错,错误码为:%i",sqlCode);
        }else {
//            NSLog(@"添加本地书籍章节到数据库成功");
            result = YES;
        }

    }
    return result;
}
//根据书籍id移除书签
-(BOOL)removeBookmark:(NSDictionary *) bookmark{
    BOOL result = NO;
    NSString *sql = [@"update bookmark set isdelete=1 where bookId=" stringByAppendingFormat:@"%i and chapterId=%i and page=%i",[[bookmark objectForKey:@"bookId"] intValue],[[bookmark objectForKey:@"chapterId"] intValue],[[bookmark objectForKey:@"page"] intValue]];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        if (sqlite3_step(stmt)!=SQLITE_DONE) {
            NSLog(@"删除书签出错");
        }else {
            result = YES;
        }
    }
    return result;
}

//根据书籍id移除书签
-(BOOL)removeBookmarkByBookId:(NSInteger) bookId{
    BOOL result = NO;
    NSString *sql = [@"update bookmark set isdelete=1 where bookId=" stringByAppendingFormat:@"%i",bookId];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        if (sqlite3_step(stmt)!=SQLITE_DONE) {
            NSLog(@"删除书签出错");
        }else {
            result = YES;
        }
    }
    return result;
}

//根据书籍id移除章节信息
-(BOOL)removeChapterByBookId:(NSInteger)bookId{
    BOOL result = NO;
    NSString *sql = [@"update bookchapter set isdelete=1 where bookId=" stringByAppendingFormat:@"%i",bookId];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        if (sqlite3_step(stmt)!=SQLITE_DONE) {
            NSLog(@"删除书签出错");
        }else {
            result = YES;
        }
    }
    return result;
}


//根据书籍id查询改书籍保存在本地的书签
-(NSArray *)getBookmarksByBookId:(int) bid chapterId:(NSUInteger)chapterId{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    const char *sql = "select * from bookmark where isdelete=0";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, sql, -1, &stmt, nil)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            NSString *_id = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
            NSString *bookId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
            NSString *chapterId = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];
            NSString *markname = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 3)];
            NSString *page = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 4)];
            NSString *isdelete = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 5)];
            NSString *addTime = [[NSString alloc] initWithUTF8String: (char *)sqlite3_column_text(stmt, 6)];
            NSMutableDictionary *bookmark = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_id,@"id" ,bookId,@"bookId",chapterId,@"chapterId",markname,@"markname", page,@"page", isdelete,@"isdelete",addTime,@"addTime",nil];
            [result addObject:bookmark];
        }
    }
    sqlite3_finalize(stmt);
    return result;
}

//书签是否已添加
-(BOOL)isBookmarkExist:(NSDictionary *)bookmark{
    BOOL result = NO;
    NSString *sql = [NSString stringWithFormat:@"%@%i%@%i%@%i",@"select * from bookmark where isdelete=0 and bookId=",[[bookmark objectForKey:@"bookId"] intValue],@" and chapterId=",[[bookmark objectForKey:@"chapterId"] intValue],@" and page=",[[bookmark objectForKey:@"page"] intValue]];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            result = YES;
            break;
        }
    }
    sqlite3_finalize(stmt);
    return result;
}


//添加阅读历史
-(BOOL)addReadHistory:(NSDictionary *)history{
    return NO;
}
//查询本地所有阅读历史
-(NSArray *)getAllReadHistory{
    return nil;
}
//根据书籍id查询阅读历史
-(NSArray *)getReadHistoryByBookId:(int) bid{
    return nil;
}

-(void)dealloc{
    sqlite3_close(self.database);
}
@end
