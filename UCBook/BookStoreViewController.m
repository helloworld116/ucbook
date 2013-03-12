//
//  BookStoreViewController.m
//  UCBook
//
//  Created by apple on 12-12-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookStoreViewController.h"
#import "BookDetailViewController.h"
#import "BookStoreView.h"
#import "NSDictionary+JSONCategories.h"
#import "SVProgressHUD.h"
#import "SqlUtils.h"

@interface BookStoreViewController ()<UITableViewDelegate>

@end

@implementation BookStoreViewController
@synthesize svContainer;
@synthesize segcontol;
@synthesize viewOfNewBooks=_viewOfNewBooks,viewOfBoutiqueBooks=_viewOfBoutiqueBooks,viewOfPopularityBooks=_viewOfPopularityBooks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.48 green:0.30 blue:0.17 alpha:1];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.22 blue:0.15 alpha:1];
    self.svContainer.contentSize = CGSizeMake(self.svContainer.frame.size.width*3, svContainer.frame.size.height);
    self.svContainer.delegate = self;
//    self.segcontol.tintColor = [UIColor grayColor];
    [self.segcontol addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self showInScreen:0];
    
//    CGRect frame = CGRectMake(0 ,123, 320, 307);
//    self.svContainer.frame = frame;
}

- (void)viewDidUnload
{
    [self setSvContainer:nil];
    [self setSegcontol:nil];
    [self setViewOfNewBooks:nil];
    [self setViewOfBoutiqueBooks:nil];
    [self setViewOfPopularityBooks:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) segmentedControlChangedValue:(id)sender{
    int selectIndex = [sender selectedSegmentIndex];
    self.svContainer.contentOffset = CGPointMake(self.view.frame.size.width*selectIndex, 0);
}


#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //水平滚动和垂直滚动都将触发该事件，只有水平方向的才执行，水平方向是UIScrollView，垂直方向是UITableView
    if (![scrollView isKindOfClass:[UITableView class]]) {
        int contentOffsetX = (int)scrollView.contentOffset.x;
        int width = (int)scrollView.frame.size.width;
        int x = -1; 
        if (contentOffsetX%width==0) {
            x = contentOffsetX/width ;
            self.segcontol.selectedSegmentIndex = x;
            [self showInScreen:x];
        }
    }else {
//        int contentOffsetX = (int)scrollView.contentOffset.x;
//        int width = (int)scrollView.frame.size.width;
//        int x = -1; 
//        if (contentOffsetX%width==0) {
//            x = contentOffsetX/width ;
//            NSLog(@"the ... is %i",x);
//        }
    }
}

-(void) showInScreen:(NSInteger) index {
    CGRect rect = self.svContainer.bounds;
    switch (index) {
        case 0:
            if (self.viewOfNewBooks==nil) {
                rect.origin.x = self.svContainer.frame.size.width*0;
                self.viewOfNewBooks = [self newBookStoreView:kUrlOfNewGoods withFrame:rect];
                [self.svContainer addSubview:self.viewOfNewBooks];
                self.svContainer.contentOffset = CGPointMake(self.svContainer.frame.size.width*0, 0);
            }
            break;
        case 1:
            if (self.viewOfBoutiqueBooks==nil) {
                rect.origin.x = self.svContainer.frame.size.width;
                self.viewOfBoutiqueBooks = [[BookStoreView alloc] initWithFrame:rect withUrl:kUrlOfRecommendGoods];
                [self.svContainer addSubview:self.viewOfBoutiqueBooks];  
                self.svContainer.contentOffset = CGPointMake(self.svContainer.frame.size.width*1, 0);
            }
            break;
        case 2:
            if (self.viewOfPopularityBooks==nil) {
                rect.origin.x = self.svContainer.frame.size.width*2;
                self.viewOfPopularityBooks = [[BookStoreView alloc] initWithFrame:rect withUrl:kUrlOfHotGoods];
                [self.svContainer addSubview:self.viewOfPopularityBooks];
                self.svContainer.contentOffset = CGPointMake(self.svContainer.frame.size.width*2, 0);
            }
            break;    
        default:
            if (self.viewOfNewBooks==nil) {
                self.viewOfNewBooks = [[BookStoreView alloc] initWithFrame:rect withUrl:kUrlOfNewGoods];
                [self.svContainer addSubview:self.viewOfNewBooks]; 
            }
            break;
    }

}

- (BookStoreView *) newBookStoreView:(NSString *) baseUrl withFrame:(CGRect) rect{
//    //1显示状态
//    [SVProgressHUD showWithStatus:@"正在载入..."];
//    NSString *url = [baseUrl stringByAppendingFormat:@"%@%u%@%u",@"&pageSize=",kDefaultPageSize,@"&currentPage=",kDefaultCurrentPage];
//    NSDictionary* data = [NSDictionary dictionaryWithContentsOfJSONURLString:url];
//    BookStoreView *bookStoreView = [[BookStoreView alloc] initWithFrame:rect];
//    bookStoreView.url = baseUrl;
//    if (data == nil|| [[data objectForKey:@"status"] intValue]==0) {
//        [SVProgressHUD dismissWithError:@"加载数据失败"];
//    }else {
//        NSDictionary* pageInfo = [data objectForKey:@"pageInfo"];
//        int totalPage = [[pageInfo objectForKey:@"totalPage"] intValue];
//        int totalNum = [[pageInfo objectForKey:@"totalNum"] intValue];
//        if (totalNum==0) {
//        }else {
//            NSMutableArray* dataInfo = [data objectForKey:@"dataInfo"];
//            bookStoreView.books = [[NSMutableArray alloc] init];
//            [bookStoreView.books addObjectsFromArray:dataInfo];
//            bookStoreView.totalPage = totalPage;
//        }
//        [SVProgressHUD dismiss];
//    }
//    return bookStoreView;
    BookStoreView *bookStoreView = [[BookStoreView alloc] initWithFrame:rect withUrl:baseUrl];
    return bookStoreView;
}
@end
