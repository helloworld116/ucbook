//
//  RJBookIndexViewController.m
//  RJTxtReader
//
//  Created by joey on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RJBookIndexViewController.h"

@interface RJBookIndexViewController ()

@end

@implementation RJBookIndexViewController

@synthesize delegate,bookIndex,chapterNum,bookmarks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)back:(id)sender{
    [self.delegate willBack];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
    [self.navigationController setToolbarHidden:YES animated:TRUE];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)indexOrbookmark:(id)sender
{
    [UIView beginAnimations:@"animation_indexOrbookmark" context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];

    if(isShowIndex)
    {
        isShowIndex = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"目录"];
        bookIndexTableView.hidden = YES;
        bookmarkTableView.hidden = NO;
        
    }
    else {
        isShowIndex = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"书签"];
        bookIndexTableView.hidden = NO;
        bookmarkTableView.hidden = YES;
    }
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.22 blue:0.15 alpha:1];
    CGRect beginFrame = self.navigationController.navigationBar.frame;
    beginFrame.origin.y = 20;
    self.navigationController.navigationBar.frame = beginFrame;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    [self.navigationController setToolbarHidden:YES animated:TRUE];
//    isShowIndex = YES;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] init];
    leftBarButtonItem.title = @"返回";
    leftBarButtonItem.target = self;
    leftBarButtonItem.action = @selector(back:);
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
//    rightItem.title = @"书签";
//    rightItem.target = self;
//    rightItem.action = @selector(indexOrbookmark:);
//    self.navigationItem.rightBarButtonItem = rightItem;
//    [rightItem release];

    
	// Do any additional setup after loading the view.
//    bookIndexTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-45)];
//    [bookIndexTableView setDelegate:self];
//    [bookIndexTableView setDataSource:self];
//    bookIndexTableView.hidden = NO;
//    [self.view addSubview:bookIndexTableView];

    self.title = @"书签";
    bookmarkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-45)];
    [bookmarkTableView setDelegate:self];
    [bookmarkTableView setDataSource:self];
//    bookmarkTableView.hidden = YES;

    [self.view addSubview:bookmarkTableView];
    
    self.bookmarks = [[NSMutableArray alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SqlUtils *sqlUtils = [[SqlUtils alloc] init];
    NSArray *bks =  [sqlUtils getBookmarksByBookId:self.bookIndex chapterId:self.chapterNum];
    [self.bookmarks removeAllObjects];
    [self.bookmarks addObjectsFromArray:bks];
    return [self.bookmarks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier: SimpleTableIdentifier];
    }
    NSDictionary *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
//    NSString *text = [bookmark objectForKey:@"markname"];
//    cell.textLabel.text = text;
    
    NSString *booktime = @"书签时间：";
    NSString *detailText = [NSString stringWithFormat:@"第%@页  ",[bookmark objectForKey:@"page"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.text = [detailText stringByAppendingString:[booktime stringByAppendingString:[bookmark objectForKey:@"addTime"]]];
    
    CGRect frame_1= CGRectMake(290, 5, 30, 30);
    UIButton* delButton= [[UIButton alloc] initWithFrame:frame_1];
    [delButton setImage:[UIImage imageNamed:@"edit_delete.png"] forState:UIControlStateNormal];
    delButton.tag = indexPath.row;
    [delButton addTarget:self action:@selector(delBookmark:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:delButton];
        
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)delBookmark:(id)sender
{
    UIButton* delButton = (UIButton*)sender;
    NSDictionary *bookmark = [self.bookmarks objectAtIndex:delButton.tag];
    SqlUtils *sqlUtils = [[SqlUtils alloc] init];
    [sqlUtils removeBookmark:bookmark];
    //刷新tableview
    [bookmarkTableView reloadData];
}

//选择事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(tableView == bookIndexTableView)
//    {
//        [self.delegate gotoChapter:indexPath.row];
//    }
//    else {
//        RJSingleBook* singleBook = [[RJBookData sharedRJBookData].books objectAtIndex:bookIndex];
//        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSMutableArray *ChatperArray = nil;
//        NSMutableArray *PageNumArray = nil;
//        NSMutableArray *BookTimeArray = nil;
//        if([[NSFileManager defaultManager] fileExistsAtPath:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_pagenum.plist"]]])
//        {
//            ChatperArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_chatper.plist"]]];
//            PageNumArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_pagenum.plist"]]];
//            BookTimeArray = [NSMutableArray arrayWithContentsOfFile:[Path stringByAppendingPathComponent:[singleBook.name stringByAppendingString:@"_booktime.plist"]]];
//        }
//        [delegate gotoPage:[[PageNumArray objectAtIndex:indexPath.row] integerValue]];
//       
//    }
    [delegate gotoPage:[[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"page"] intValue]];
    [self back:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
