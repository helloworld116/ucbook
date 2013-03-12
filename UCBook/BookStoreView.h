//
//  BookStoreTableView.h
//  UCBook
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookStoreView : UITableView
//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,readwrite) BOOL loadingmore;

@property (nonatomic,retain) NSString *url;

@property (nonatomic,retain) NSMutableArray *books;

@property (nonatomic,readwrite) NSInteger totalPage;

- (id)initWithFrame:(CGRect)frame withUrl:(NSString *)url;
@end
