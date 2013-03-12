//
//  CommentTableView.m
//  UCBook
//
//  Created by apple on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "CommentTableView.h"
#import "AppDelegate.h"
#import "Toast.h"
#import "BookDetailViewController.h"
#import "LoadingMoreFooterView.h"
#import "NSDictionary+JSONCategories.h"
#import "SVProgressHUD.h"

#define LOADINGVIEW_HEIGHT 44

@interface CommentTableView ()
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger pageSize;
@property (nonatomic) NSInteger totalNum;
@property (nonatomic,retain) LoadingMoreFooterView *loadFooterView;//加载更多 
@property BOOL isFinishedLoad;
@end

@implementation CommentTableView
@synthesize comments=_comments;
@synthesize bookId=_bookId;
@synthesize currentPage=_currentPage;
@synthesize totalPage=_totalPage;
@synthesize pageSize=_pageSize;
@synthesize totalNum=_totalNum;
@synthesize loadingmore=_loadingmore,loadFooterView=_loadFooterView;
@synthesize isFinishedLoad = _isFinishedLoad;
@synthesize isRefreshing=_isRefreshing;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code 
//        self.currentPage = 1;
//        self.loadFooterView = [[LoadingMoreFooterView alloc]initWithFrame:CGRectZero];
//        [self addSubview:self.loadFooterView];
//        
//        self.dataSource = self;
//        self.delegate = self;
//        self.currentPage = 1;
//        self.pageSize = kCommentPageSize;
//        
//        //handle data
////        NSDictionary *pageInfo = [self.commentInfo objectForKey:@"pageInfo"];
//    }
//    return self;
//}
//
- (id)initWithFrame:(CGRect)frame withBookId:(NSString *) bookId
{
    self = [super initWithFrame:frame];
    self.delegate = self;
    self.bookId = bookId;
    self.currentPage = 1;
    if (self) {
        self.comments = [[NSMutableArray alloc] init];
        //1显示状态
        [SVProgressHUD showWithStatus:@"正在载入..."];
        //2从系统中获取一个并行队列
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //3在后台线程创建图像选择器
        dispatch_async(concurrentQueue, ^{
            NSDictionary* data = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfBookComments];
            //4让主线程显示图像选择器
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadFooterView = [[LoadingMoreFooterView alloc]initWithFrame:CGRectZero];
                [self addSubview:self.loadFooterView];
                self.dataSource = self;
                self.isFinishedLoad = YES;
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
                        [self.comments addObjectsFromArray:dataInfo];
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
    self.comments=nil;
    self.bookId=nil;
    self.loadFooterView=nil;
}

- (void)doneLoadingTableViewData
{
    if (self.isRefreshing)
    {
        self.isRefreshing = NO;
        self.currentPage = 1;
        [self.comments removeAllObjects];
    }
    if (self.loadingmore) {
        self.loadFooterView.showActivityIndicator = NO;
    }
    NSDictionary* data = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfBookComments];
    NSDictionary* pageInfo = [data objectForKey:@"pageInfo"];
    self.totalPage = [[pageInfo objectForKey:@"totalPage"] intValue];
    if (self.totalPage>self.currentPage) {
        self.loadingmore = YES; 
    }else {
        self.loadingmore = NO;
    }
    NSArray *dataInfo = [data objectForKey:@"dataInfo"];
    [self.comments addObjectsFromArray:dataInfo];
    [self reloadData];

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"commentCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {  
//        // Create a cell to display an ingredient.  
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle   
//                                      reuseIdentifier:CellIdentifier];  
//    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle   
                                                   reuseIdentifier:CellIdentifier];
    if (indexPath.row==0) {
        CGRect commentListRect = CGRectMake(10, 5, 70, 40);
        UILabel *lblOfCommentList = [[UILabel alloc] initWithFrame:commentListRect];
        lblOfCommentList.font = [UIFont fontWithName:@"Helvetica" size:16];
        lblOfCommentList.textColor = [UIColor blueColor];
        lblOfCommentList.textAlignment = UITextAlignmentCenter;
        lblOfCommentList.text = @"评论列表";
        lblOfCommentList.backgroundColor = [UIColor clearColor];
        
        CGRect segmentImgRect = CGRectMake(90, 15, 2, 20);
        UIImageView *imgVOfSegment = [[UIImageView alloc] initWithFrame:segmentImgRect];
        imgVOfSegment.image = [UIImage imageNamed:@"segment"];
        
        CGRect penImgRect = CGRectMake(110, 16, 15, 16);
        UIImageView *imgVOfPen = [[UIImageView alloc] initWithFrame:penImgRect];
        imgVOfPen.image = [UIImage imageNamed:@"pen"];
        
        CGRect lblOfAddCommentRect = CGRectMake(125, 5, 70, 40);
        UILabel *lblOfAddComment = [[UILabel alloc] initWithFrame:lblOfAddCommentRect];
        lblOfAddComment.font = [UIFont fontWithName:@"Helvetica" size:16];
        lblOfAddComment.textColor = [UIColor greenColor];
        lblOfAddComment.textAlignment = UITextAlignmentCenter;
        lblOfAddComment.text = @"我要评论";
        lblOfAddComment.backgroundColor = [UIColor clearColor];
        
        CGRect hiddenBtnRect = CGRectMake(110, 5, 85, 40);
        UIButton *hiddenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hiddenBtn.frame = hiddenBtnRect;
        [hiddenBtn addTarget:[self viewController] action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:lblOfCommentList];
        [cell addSubview:imgVOfSegment];
        [cell addSubview:imgVOfPen];
        [cell addSubview:lblOfAddComment];
        [cell addSubview:hiddenBtn];
    }else {
        NSDictionary *comment = [self.comments objectAtIndex:indexPath.row-1];
        
        CGSize contentHeight = [[comment objectForKey:@"content"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        CGRect rectOfLblContent = CGRectMake(5, 2, 310, contentHeight.height);  
        UILabel *lblOfContent = [[UILabel alloc] initWithFrame:rectOfLblContent];
        lblOfContent.textAlignment = UITextAlignmentLeft;
        lblOfContent.lineBreakMode = UILineBreakModeWordWrap;
        lblOfContent.numberOfLines = 0;
        lblOfContent.font = [UIFont fontWithName:@"Helvetica" size:15];
        lblOfContent.text = [comment objectForKey:@"content"];
        
        CGRect rectOfLblAuthor = CGRectMake(5, contentHeight.height+10, 150, 15);
        UILabel *lblOfAuthor = [[UILabel alloc] initWithFrame:rectOfLblAuthor];
        lblOfAuthor.font = [UIFont fontWithName:@"Helvetica" size:13];
        lblOfAuthor.textAlignment = UITextAlignmentLeft;
        lblOfAuthor.text = [comment objectForKey:@"user_name"];
        lblOfAuthor.textColor = [UIColor grayColor];
        
        CGRect rectOfLblTime = CGRectMake(160, contentHeight.height+10, 155, 15);
        UILabel *lblOfTime = [[UILabel alloc] initWithFrame:rectOfLblTime];
        lblOfTime.font = [UIFont fontWithName:@"Helvetica" size:13];
        lblOfTime.textAlignment = UITextAlignmentRight;
        lblOfTime.text = [comment objectForKey:@"add_time"];
        lblOfTime.textColor = [UIColor grayColor];
        
        [cell addSubview:lblOfContent];
        [cell addSubview:lblOfAuthor];
        [cell addSubview:lblOfTime];
    }
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    static CGFloat height = 0;
    height+=[self rectForRowAtIndexPath:indexPath].size.height;
    if (self.loadingmore&&(indexPath.row+1)==[self.comments count]) {
        self.loadFooterView.frame = CGRectMake(0, height, self.frame.size.width, LOADINGVIEW_HEIGHT);
        self.loadFooterView.textLabel.text=@"上拉加载更多...";
        CGSize size = self.contentSize;
        self.contentSize = CGSizeMake(size.width, size.height+LOADINGVIEW_HEIGHT);
    }
    return cell;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    CGRect rect = CGRectMake(0, 0, self.frame.size.width, 50);
//    UIView *cell = [[UIView alloc] initWithFrame:rect];
//    
//    CGRect commentListRect = CGRectMake(10, 5, 70, 40);
//    UILabel *lblOfCommentList = [[UILabel alloc] initWithFrame:commentListRect];
//    lblOfCommentList.font = [UIFont fontWithName:@"Helvetica" size:16];
//    lblOfCommentList.textColor = [UIColor blueColor];
//    lblOfCommentList.textAlignment = UITextAlignmentCenter;
//    lblOfCommentList.text = @"评论列表";
//    lblOfCommentList.backgroundColor = [UIColor clearColor];
//    
//    CGRect segmentImgRect = CGRectMake(90, 15, 2, 20);
//    UIImageView *imgVOfSegment = [[UIImageView alloc] initWithFrame:segmentImgRect];
//    imgVOfSegment.image = [UIImage imageNamed:@"segment"];
//    
//    CGRect penImgRect = CGRectMake(110, 16, 15, 16);
//    UIImageView *imgVOfPen = [[UIImageView alloc] initWithFrame:penImgRect];
//    imgVOfPen.image = [UIImage imageNamed:@"pen"];
//    
//    CGRect lblOfAddCommentRect = CGRectMake(125, 5, 70, 40);
//    UILabel *lblOfAddComment = [[UILabel alloc] initWithFrame:lblOfAddCommentRect];
//    lblOfAddComment.font = [UIFont fontWithName:@"Helvetica" size:16];
//    lblOfAddComment.textColor = [UIColor greenColor];
//    lblOfAddComment.textAlignment = UITextAlignmentCenter;
//    lblOfAddComment.text = @"我要评论";
//    lblOfAddComment.backgroundColor = [UIColor clearColor];
//    
//    CGRect hiddenBtnRect = CGRectMake(110, 5, 85, 40);
//    UIButton *hiddenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    hiddenBtn.frame = hiddenBtnRect;
//    [hiddenBtn addTarget:[self viewController] action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
//    
//    [cell addSubview:lblOfCommentList];
//    [cell addSubview:imgVOfSegment];
//    [cell addSubview:imgVOfPen];
//    [cell addSubview:lblOfAddComment];
//    [cell addSubview:hiddenBtn];
//    return cell;
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.isFinishedLoad) {
        if (self.totalNum==0) {
            UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 30)];
            footer.textAlignment = UITextAlignmentCenter;
            footer.text = @"暂时还没有评论，等你来抢沙发哦。。。";
            footer.backgroundColor = [UIColor clearColor];
            return footer;
        }else if(self.totalNum<=4){
            UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
            footer.backgroundColor = [UIColor clearColor];
            return footer;
        }else{
            return nil;
        }
    }else {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 50;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isFinishedLoad&&self.totalNum==0) {
        return 30;
    }else {
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 50;
    }else {
        NSDictionary *comment = [self.comments objectAtIndex:indexPath.row-1];
        CGSize contentHeight = [[comment objectForKey:@"content"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        return contentHeight.height+30;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comments count]+1;
}


-(BookDetailViewController *)viewController{
    for (UIView *next = [self superview]; next; next = [next superview]) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[BookDetailViewController class]]) {
            return (BookDetailViewController *)nextResponder;
        }
    }
    return nil;
}

//-(void)addComment{
//    if (SharedApp.ticket==nil) {
//        [Toast showWithText:@"请先登录" bottomOffset:60 duration:3];
//        UITabBarController *tabBarController = (UITabBarController *)[self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
//        tabBarController.selectedIndex = 2;
//        tabBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        tabBarController.modalPresentationStyle = UIModalTransitionStylePartialCurl;
//        [self presentViewController:tabBarController animated:YES completion:nil];
//    }else {
//    }
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    NSLog(@"add comment");
//}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if ([self.comments count]<=5) {
//		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 1)];
//		footer.backgroundColor = [UIColor clearColor];
//		return footer;
//	} else {
//		return nil;
//	}
//}
@end
