//
//  BookStoreTableView.m
//  UCBook
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BookStoreView.h"
#import "BookDetailViewController.h"
#import "LoadingMoreFooterView.h"
#import "EGORefreshTableHeaderView.h"
#import "AsyncImageView.h"
#import "BookStoreTableCell.h"
#import "CommonUtils.h"
#import "NSDictionary+JSONCategories.h"
#import "SqlUtils.h"
#import "BookStoreViewController.h"
#import "SVProgressHUD.h"

#define LOADINGVIEW_HEIGHT 44
#define REFRESHINGVIEW_HEIGHT 88

@interface BookStoreView() <EGORefreshTableHeaderDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain) LoadingMoreFooterView *loadFooterView;//加载更多 
@property(nonatomic, retain) EGORefreshTableHeaderView * refreshHeaderView;  //下拉刷新
@property(nonatomic, readwrite) BOOL isRefreshing; 
@property(nonatomic) int currentPage;
@property(nonatomic) int totalNum;

@property(nonatomic,retain) SqlUtils *sqlUtils;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end

@implementation BookStoreView
//@synthesize tableView = _tableView;
@synthesize loadFooterView=_loadFooterView,loadingmore=_loadingmore;
@synthesize refreshHeaderView=_refreshHeaderView,isRefreshing=_isRefreshing;
@synthesize currentPage=_currentPage;

@synthesize url=_url;
@synthesize books=_books;
@synthesize totalPage=_totalPage;
@synthesize totalNum=_totalNum;

@synthesize sqlUtils=_sqlUtils;

- (id)initWithFrame:(CGRect)frame withUrl:(NSString *)baseurl
{
    self = [super initWithFrame:frame];
    if (self) {
        self.books = [[NSMutableArray alloc] init];
        self.delegate = self;
        self.rowHeight = 85;
        self.url = baseurl;
        //1显示状态
        [SVProgressHUD showWithStatus:@"正在载入..."];
        //2从系统中获取一个并行队列
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //3在后台线程创建图像选择器
        dispatch_async(concurrentQueue, ^{
            NSString *url = [baseurl stringByAppendingFormat:@"%@%u%@%u",@"&pageSize=",kDefaultPageSize,@"&currentPage=",kDefaultCurrentPage];
            NSDictionary* data = [NSDictionary dictionaryWithContentsOfJSONURLString:url];
            //4让主线程显示图像选择器
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showsHorizontalScrollIndicator = NO;
                self.showsVerticalScrollIndicator = NO;
                self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,  -REFRESHINGVIEW_HEIGHT, self.frame.size.width,REFRESHINGVIEW_HEIGHT)];
                [self addSubview:self.refreshHeaderView];
                self.refreshHeaderView.delegate = self;
                [self.refreshHeaderView refreshLastUpdatedDate];
                self.isRefreshing = NO;
                self.loadFooterView = [[LoadingMoreFooterView alloc]initWithFrame:CGRectZero];
                [self addSubview:self.loadFooterView];
                self.dataSource = self;
                self.sqlUtils = [[SqlUtils alloc] init];
                if (data == nil|| [[data objectForKey:@"status"] intValue]==0) {
                    [SVProgressHUD dismissWithError:@"加载数据失败"];
                }else {
                    NSDictionary* pageInfo = [data objectForKey:@"pageInfo"];
                    self.totalPage = [[pageInfo objectForKey:@"totalPage"] intValue];
                    self.totalNum = [[pageInfo objectForKey:@"totalNum"] intValue];
                    self.currentPage = [[pageInfo objectForKey:@"currentPage"] intValue];
                    if (self.totalPage>self.currentPage) {
                        self.loadingmore = YES;
                        self.loadFooterView.textLabel.text=@"上拉加载更多...";
                    }else {
                        self.loadingmore = NO;
                        self.loadFooterView.textLabel.text=@"";
                    }
                    if (self.totalNum==0) {
                    }else {
                        NSMutableArray* dataInfo = [data objectForKey:@"dataInfo"];
                        [self.books addObjectsFromArray:dataInfo];
                    }
                    [SVProgressHUD dismiss];
                }
            });
        });
    }
    return self;
}

- (void)dealloc
{
//    self.tableView = nil;
    self.loadFooterView = nil;
    self.refreshHeaderView = nil;
    self.url = nil;
    self.books = nil;
    self.sqlUtils = nil;
}

#pragma mark- EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
    self.currentPage = 1;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:3.0f];  //make a delay to show loading process for a while
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.isRefreshing; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; 
}

- (void)doneLoadingTableViewData
{
    if (self.isRefreshing||self.loadingmore) {
        if (self.isRefreshing)
        {
            self.isRefreshing = NO;
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
            [self.books removeAllObjects];
        }
        if (self.loadingmore) {
            self.loadFooterView.showActivityIndicator = NO;
        }
        NSString *url = [self.url stringByAppendingFormat:@"%@%u%@%u",@"&pageSize=",kDefaultPageSize,@"&currentPage=",self.currentPage];
        NSDictionary* data = [NSDictionary dictionaryWithContentsOfJSONURLString:url];
        NSDictionary* pageInfo = [data objectForKey:@"pageInfo"];
        self.totalPage = [[pageInfo objectForKey:@"totalPage"] intValue];
        if (self.totalPage>self.currentPage) {
            self.loadingmore = YES; 
        }else {
            self.loadingmore = NO;
        }
        NSArray *dataInfo = [data objectForKey:@"dataInfo"];
        [self.books addObjectsFromArray:dataInfo];
        [self reloadData];
    }
}

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	self.isRefreshing = YES;
	
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= scrollView.contentSize.height ) 
    {
        if (!self.loadingmore) return;
        self.loadFooterView.showActivityIndicator = YES;
        
        self.currentPage ++;
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:1.0f]; //make a delay to show loading process for a while
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"BookStoreTableCell"
                                                    owner:self options:nil];
    BookStoreTableCell * cell = (BookStoreTableCell *)[bundle objectAtIndex:0];
    NSDictionary *book = [self.books objectAtIndex:indexPath.row];
    //    [book objectForKey:@"goods_img"];//中图
    [cell.imgViewOfFrontConver loadImage:[book objectForKey:@"goods_thumb"]];//小图
    cell.lblOfName.text = [book objectForKey:@"goods_name"];
    [cell.lblOfOriginalPrice setStrikeThroughEnabled:YES];
    cell.lblOfOriginalPrice.text = [NSString stringWithFormat:@"%@%@" ,@"￥",[book objectForKey:@"market_price"]];
    cell.lblOfCurrentPrice.text = [NSString stringWithFormat:@"%@%@" ,@"￥",[CommonUtils showPrice:[book objectForKey:@"promote_price"]]];
//    cell.lblOfCurrentPrice.text = @"￥0.00";
    cell.lblOfClickCount.text = [book objectForKey:@"click_count"];
    //如果本地已下载
    if ([[self.sqlUtils getLocalBookIds] containsObject:[book objectForKey:@"goods_id"]]) {
        cell.imgViewOfDownload.image = [UIImage imageNamed:@"downloaded.png"];
    }
    if (self.loadingmore&&(indexPath.row+1)==[self.books count]) {
        self.loadFooterView.frame = CGRectMake(0, self.rowHeight*(indexPath.row+1), self.frame.size.width, LOADINGVIEW_HEIGHT);
        self.loadFooterView.textLabel.text=@"上拉加载更多...";
//        NSLog(@"loadmoreview subview is %@",[self.loadFooterView subviews]);
        CGSize size = self.contentSize;
        self.contentSize = CGSizeMake(size.width, size.height+LOADINGVIEW_HEIGHT);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookStoreViewController *bookStoreViewController = [self viewController];
    BookDetailViewController *detailViewController = (BookDetailViewController *)[bookStoreViewController.storyboard instantiateViewControllerWithIdentifier:@"bookDetailViewController"];
    detailViewController.hidesBottomBarWhenPushed = YES;
    detailViewController.bookId = [[self.books objectAtIndex:indexPath.row] objectForKey:@"goods_id"];
    detailViewController.title = [[self.books objectAtIndex:indexPath.row] objectForKey:@"goods_name"];
    [bookStoreViewController.navigationController pushViewController:detailViewController animated:YES];
}


-(BookStoreViewController *)viewController{
    for (UIView *next = [self superview]; next; next = [next superview]) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[BookStoreViewController class]]) {
            return (BookStoreViewController *)nextResponder;
        }
    }
    return nil;
}

@end
