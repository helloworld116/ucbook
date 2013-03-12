//
//  CommentTableView.h
//  UCBook
//
//  Created by apple on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableView : UITableView<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic,retain) NSMutableArray *comments;
@property (nonatomic,copy) NSString *bookId;
@property(nonatomic,readwrite) BOOL loadingmore;
@property(nonatomic,readwrite) BOOL isRefreshing;
@property (nonatomic,readwrite) NSInteger totalPage;

- (void)doneLoadingTableViewData;
- (id)initWithFrame:(CGRect)frame withBookId:(NSString *) bookId;
@end
