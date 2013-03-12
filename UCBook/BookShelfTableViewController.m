//
//  BookShelfTableViewController.m
//  UCBook
//
//  Created by apple on 12-12-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookShelfTableViewController.h"
#import "ReadBooks.h"
#import "SqlUtils.h"
#import "KDBooKViewController.h"
#import "Toast.h"
#import "BookStoreViewController.h"

@interface BookShelfTableViewController ()<UIAlertViewDelegate>
@property NSInteger removeBookId;
@end

@implementation BookShelfTableViewController
@synthesize books=_books;
@synthesize removeBookId=_removeBookId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.22 blue:0.15 alpha:1];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3.png"]];
    self.tableView.separatorStyle = NO;
    self.tableView.backgroundView = backgroundView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    SqlUtils *sqlUtils = [[SqlUtils alloc] init];
    self.books = [[NSMutableArray alloc] init];
    [self.books addObjectsFromArray:[sqlUtils getLocalBooks]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int bookCount = [self.books count];
    int row = bookCount%3==0?(bookCount/3):(bookCount/3+1);
    return row>3?row:3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookShelfCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.png"]];
    cell.backgroundView = backgroundView;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//选中cell样式不发生改变
    
    // Configure the cell...
    UIButton *button = nil;
    for (int i = 0; i < 3; i++) {
        if ([self.books count]>indexPath.row*3+i) {
            NSDictionary *book = [self.books objectAtIndex:(indexPath.row*3+i)];
            if (book!=nil) {
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(10 + ((320 - 40) / 3 + 10) * i, 1, (320 - 40) / 3, 105);
                button.tag = [[book objectForKey:@"bookId"] intValue];
                NSString *coverUri = [NSHomeDirectory() stringByAppendingPathComponent:[book objectForKey:@"coverUri"]];
                [button setImage:[[UIImage alloc] initWithContentsOfFile:coverUri] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
                UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromShelf:)];
                longPressGR.minimumPressDuration = 0.3;
                [button addGestureRecognizer:longPressGR];
                [cell addSubview:button];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 122.f;
}

-(void)removeFromShelf:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIButton *btn = (UIButton *)[sender view];
        self.removeBookId = btn.tag;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定从书架上移除该书?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex==0) {
        SqlUtils *sqlUtils = [[SqlUtils alloc] init];
        if ([sqlUtils removeLocalBook:self.removeBookId]) {
            [sqlUtils removeBookmarkByBookId:self.removeBookId];
            [sqlUtils removeChapterByBookId:self.removeBookId];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"书籍删除成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alertView show];
            //更新书城页面
            UINavigationController *bookStoreNavigationController = (UINavigationController *)[[SharedApp.tabBarController viewControllers] objectAtIndex:1];
            BookStoreViewController *bookstroreViewController = (BookStoreViewController *)[[bookStoreNavigationController viewControllers] objectAtIndex:0];
            if (bookstroreViewController.viewOfNewBooks!=nil) {
                [bookstroreViewController.viewOfNewBooks reloadData];
            }
            if (bookstroreViewController.viewOfBoutiqueBooks!=nil) {
                [bookstroreViewController.viewOfBoutiqueBooks reloadData];
            }
            if (bookstroreViewController.viewOfPopularityBooks!=nil) {
                [bookstroreViewController.viewOfPopularityBooks reloadData];
            }

            [self.books removeAllObjects];
            NSArray *books = [sqlUtils getLocalBooks];
            [self.books addObjectsFromArray:books];
            //更新页面
            //更新书架页面
            [self.tableView reloadData];

        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"书籍删除失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alertView show];
        }
    }
    self.removeBookId = 0;
}

- (void) onClick:(id) sender{
    UIButton *button = (UIButton *)sender;
    NSLog(@"bookId is %i",button.tag);
//    SqlUtils *sqlUtils = [[SqlUtils alloc] init];
//    NSArray *chapters = [sqlUtils getBookChaptersByBookId:button.tag];
//    NSString *filePath = nil;
//    if ([chapters count]>0) {
//        filePath = [[chapters objectAtIndex:0] objectForKey:@"fileUri"];
//    }
//    NSString *bookFilePath=[NSHomeDirectory() stringByAppendingPathComponent:filePath]; 
//    NSLog(@"book file path is %@",bookFilePath);
//    //gb18030
//    NSString *str = [NSString stringWithContentsOfFile:bookFilePath encoding:-2147482062 error:nil];   ReadBooks *readBooks = [[ReadBooks alloc] init];
//    readBooks.str = str;
//    //设置翻转模式
//    [readBooks setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    [self presentModalViewController:readBooks animated:YES];
    
    KDBooKViewController *bookVC = [[KDBooKViewController alloc] init];
	bookVC.bookIndex = button.tag;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:bookVC];
    navigationController.hidesBottomBarWhenPushed = YES;
//    [navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:navigationController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
