//
//  BookDetailViewController.m
//  UCBook
//
//  Created by apple on 12-12-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookDetailViewController.h"
#import "SVProgressHUD.h"
#import "NSDictionary+JSONCategories.h"
#import "CommonUtils.h"
#import "DownloadUtils.h"
#import "ZipArchive.h"
#import "SqlUtils.h"
#import "Toast.h"
#import "AppDelegate.h"
#import "BookStoreViewController.h"
#import "ReadBooks.h"
#import "AddCommentViewController.h"
#import "BookShelfTableViewController.h"
#import "LoginViewController.h"
#import "KDBooKViewController.h"
#import "AlixPayOrder.h"
#import "AlixPayResult.h"
#import "AlixPay.h"
#import "DataSigner.h"
#import "base64.h"
#import "CBiOSStoreManager.h"

@interface BookDetailViewController ()<UIScrollViewDelegate,UIWebViewDelegate,UITableViewDelegate, ASIHTTPRequestDelegate>
@property (nonatomic,retain) UIProgressView *progressView;//进度条
@property (nonatomic,copy) NSString* key;//下载时用到的key
@property (nonatomic,retain) ASINetworkQueue *networkQueue;
@property float fileLength;
@property (nonatomic,copy) NSString *downloadPath;
@property (nonatomic,copy) NSString *unzipPath;
@property (nonatomic,retain) SqlUtils *sqlUtils;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger pageSize;
@end

@implementation BookDetailViewController
@synthesize progressView=_progressView;
@synthesize imgViewOfBookCover = _imgViewOfBookCover;
@synthesize lblBookName=_lblBookName;
@synthesize lblAuthor=_lblAuthor;
@synthesize lblPrice = _lblPrice;
@synthesize lblOriginalPrice=_lblOriginalPrice;
@synthesize lblWordCount=_lblWordCount;
@synthesize lblOfBeginRead = _lblOfBeginRead;
@synthesize lblOfDownload = _lblOfDownload;
@synthesize btnOfBeginRead = _btnOfBeginRead;
@synthesize btnOfDownload = _btnOfDownload;
@synthesize segment = _segment;
@synthesize svContainer=_svContainer;
@synthesize webViewIntr = _webViewIntr;
@synthesize tableViewChara = _tableViewChara;
@synthesize tableViewComment=_tableViewComment;
@synthesize bookId=_bookId;
@synthesize bookDetail=_bookDetail;
@synthesize key=_key;

@synthesize networkQueue=_networkQueue;
@synthesize fileLength=_fileLength;
@synthesize downloadPath=_downloadPath;
@synthesize unzipPath=_unzipPath;
@synthesize sqlUtils=_sqlUtils;
@synthesize currentPage=_currentPage;
@synthesize pageSize=_pageSize;

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
    self.sqlUtils = [[SqlUtils alloc] init];
//    [self.view setHidden:YES];
//    [self.view setAlpha:0];
//    self.segment.tintColor = [UIColor grayColor];
//    self.btnOfDownload setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>
    [self.segment addTarget:self
                         action:@selector(segmentedControlChangedValue:)
           forControlEvents:UIControlEventValueChanged];
    self.svContainer.delegate = self;
    //1显示状态
    [SVProgressHUD showWithStatus:@"正在载入..."];
    //2从系统中获取一个并行队列
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3在后台线程创建图像选择器
    dispatch_async(concurrentQueue, ^{        
        self.bookDetail = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfBooksDetail];
        //4让主线程显示图像选择器
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.bookDetail==nil||[[self.bookDetail objectForKey:@"status"] intValue]==0) {
                [SVProgressHUD dismissWithError:@"加载失败"];
            }else {
                NSDictionary *bookDetail = [[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"];
                NSString *imgUrl = [NSString stringWithFormat:@"%@/%@/%@",[[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"imgserver"],[bookDetail objectForKey:@"shop_id"],[bookDetail objectForKey:@"goods_img"]];
                CGRect rect = self.imgViewOfBookCover.bounds;
                rect.size.height = 139;//xib中设置为148，但是显示高度只有55，不知道哪里引起
                self.imgViewOfBookCover.frame = rect;
                [self.imgViewOfBookCover loadImage:imgUrl];
                self.lblBookName.text = [bookDetail objectForKey:@"goods_name"];
                self.lblPrice.text = [NSString stringWithFormat:@"%@%@",@"￥",[CommonUtils showPrice:[bookDetail objectForKey:@"promote_price"]]];//shop_price,market_price,promote_price
//                self.lblPrice.text = @"￥0.00";
                self.lblAuthor.text = [bookDetail objectForKey:@"author"];
                [self.lblOriginalPrice setStrikeThroughEnabled:YES];
                self.lblOriginalPrice.text = [NSString stringWithFormat:@"%@%@",@"￥",[bookDetail objectForKey:@"market_price"]];
                self.lblWordCount.text = @"";
                
                if([[self.sqlUtils getLocalBookIds] containsObject:[bookDetail objectForKey:@"goods_id"]]){
                    self.lblOfDownload.textColor = [UIColor whiteColor];
                    self.lblOfDownload.text=@"已下载";
                    self.btnOfDownload.enabled = NO;
                    self.lblOfDownload.backgroundColor = self.lblOfBeginRead.backgroundColor;           
                }
            
                CGRect svRect = self.svContainer.frame;
//                NSLog(@"y is %f",self.svContainer.frame.origin.y);
                svRect.origin.y = 174;//xib中设置为182，但是实际输出89，不知道哪里引起
                svRect.size.height +=49;
                self.svContainer.frame = svRect;
                self.svContainer.contentSize = CGSizeMake(self.svContainer.frame.size.width*3, self.svContainer.frame.size.height);
           
                self.webViewIntr = [[UIWebView alloc] initWithFrame:self.svContainer.bounds];
                // [(UIScrollView *)[[self.webViewIntr subviews] objectAtIndex:0] setBounces:NO];
                self.webViewIntr.delegate = self;
                [self.webViewIntr loadHTMLString:[bookDetail objectForKey:@"goods_desc"] baseURL:nil];
                [self.svContainer addSubview:self.webViewIntr];  
                [SVProgressHUD dismiss];   
//                [self.view setHidden:NO];
//                [self.view setAlpha:1];
            }
        });
    });
}


-(void) segmentedControlChangedValue:(id)sender{
    int selectIndex = [sender selectedSegmentIndex];
    self.svContainer.contentOffset = CGPointMake(self.view.frame.size.width*selectIndex, 0);
}

- (void)viewDidUnload
{
    [self setLblBookName:nil];
    [self setLblAuthor:nil];
    [self setLblOriginalPrice:nil];
    [self setLblWordCount:nil];
    [self setSvContainer:nil];
    [self setImgViewOfBookCover:nil];
    [self setLblPrice:nil];
    [self setSegment:nil];
    [self setWebViewIntr:nil];
    [self setTableViewChara:nil];
    [self setTableViewComment:nil];
    [self setLblOfBeginRead:nil];
    [self setLblOfDownload:nil];
    [self setBtnOfBeginRead:nil];
    [self setBtnOfDownload:nil];
    
    
    [self setBookDetail:nil];
    [self setKey:nil];
    [self setNetworkQueue:nil];
    [self setDownloadPath:nil];
    [self setUnzipPath:nil];
    [self setSqlUtils:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//返回时重新加载
-(void)reloadTableData{
    NSLog(@"load");
}
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (![scrollView isKindOfClass:[UITableView class]]) {
        int contentOffsetX = (int)scrollView.contentOffset.x;
        int width = (int)scrollView.frame.size.width;
        int x = -1; 
        if (contentOffsetX%width==0) {
            x = contentOffsetX/width ;
            self.segment.selectedSegmentIndex = x;
            [self showInScreen:x];
        }
    }   
}

-(void) showInScreen:(NSInteger) index {
    NSLog(@"the frame is %f",self.svContainer.frame.size.height);
    CGRect rect = self.svContainer.bounds;
    switch (index) {
//        case 0:
//            if (self.webViewIntr==nil) {
//                self.webViewIntr = [[UIWebView alloc] initWithFrame:rect];
//                // [(UIScrollView *)[[self.webViewIntr subviews] objectAtIndex:0] setBounces:NO];
//                self.webViewIntr.delegate = self;
//                [self.webViewIntr loadHTMLString:[self.bookDetail objectForKey:@"goods_desc"] baseURL:nil];
//                [self.svContainer addSubview:self.webViewIntr];   
//            }
//            break;
        case 1:
            if (self.tableViewChara==nil) {
                rect.origin.x = self.svContainer.frame.size.width;
                self.tableViewChara = [[BookCharacterTableView alloc] initWithFrame:rect];
                self.tableViewChara.delegate = self;
                self.tableViewChara.characters = [[[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"] objectForKey:@"chapter"];
                [self.svContainer addSubview:self.tableViewChara];  
                self.svContainer.contentOffset = CGPointMake(self.svContainer.frame.size.width*1, 0);
            }
            break;
        case 2:
            if(self.tableViewComment==nil){
//                self.pageSize = 10;
//                self.currentPage=1;
//                NSDictionary *result=[NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfBookComments];
//                rect.origin.x = self.svContainer.frame.size.width*2;
//                self.tableViewComment = [CommentTableView alloc];
//                self.tableViewComment.commentInfo = result;
//                self.tableViewComment = [self.tableViewComment initWithFrame:rect];
//                self.tableViewComment.bookId = self.bookId;
//                self.tableViewComment.url = kUrlOfBookComments;
                self.tableViewComment = [[CommentTableView alloc] initWithFrame:rect withBookId:self.bookId];
                [self.svContainer addSubview:self.tableViewComment];  
                self.svContainer.contentOffset = CGPointMake(self.svContainer.frame.size.width*2, 0);
            }
            break;
        default:
            break;
    }
}

#pragma mark- UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    CGFloat webViewHeight = webView.scrollView.contentSize.height;
//    self.svContainer.contentSize = CGSizeMake(self.svContainer.contentSize.width, webViewHeight);
//    CGRect rect = self.webViewIntr.frame;
//    rect.size.height +=webViewHeight;
//    [self.webViewIntr setFrame:rect];
}

#pragma mark 点击开始阅读和下载事件
- (IBAction)beginRead:(id)sender {
    //书籍已下载到本地
    if ([[self.sqlUtils getLocalBookIds] containsObject:self.bookId]) {
        KDBooKViewController *bookVC = [[KDBooKViewController alloc]init];
        bookVC.bookIndex = [self.bookId intValue];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:bookVC];
        navigationController.hidesBottomBarWhenPushed = YES;
        [navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentModalViewController:navigationController animated:YES];
    }else {
        //书籍没有下载到本地
        [Toast showWithText:@"请先下载书籍，再开始阅读" bottomOffset:20 duration:2];
    }
}

//添加评论
-(void)addComment{
    if (![self isUserLogged]) {
        return;
    }else{
        AddCommentViewController *addCommentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addCommentViewController"];
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonSystemItemCancel target:addCommentViewController action:@selector(popViewController)];
        UIBarButtonItem *publishBtn = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonSystemItemSave target:addCommentViewController action:@selector(publishComment)];
        addCommentViewController.navigationItem.leftBarButtonItem = backBtn;
        addCommentViewController.navigationItem.rightBarButtonItem = publishBtn;
        addCommentViewController.title = @"发表评论";
        addCommentViewController.bookId = self.bookId;
        [self.navigationController pushViewController:addCommentViewController animated:YES];
    }
}
- (BOOL)isUserLogged{
    if (SharedApp.ticket==nil) {
        [Toast showWithText:@"请先登录" bottomOffset:60 duration:3];
//        UITabBarController *tabBarController = SharedApp.tabBarController;
//        tabBarController.selectedIndex = 2;
        LoginViewController *loginViewController = (LoginViewController *)[self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:loginViewController action:@selector(back)];
        loginViewController.navigationItem.leftBarButtonItem = backItem;
        [self.navigationController pushViewController:loginViewController animated:YES];
    
//        tabBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        tabBarController.modalPresentationStyle = UIModalTransitionStylePartialCurl;
//        [self presentViewController:tabBarController animated:YES completion:nil];
        return NO;
    }else {
        return YES;
    }
}

/*
 *随机生成15位订单号,外部商户根据自己情况生成订单号
 */
- (NSString *)generateTradeNO
{
	const int N = 15;
	
	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *result = [[NSMutableString alloc] init];
	srand(time(0));
	for (int i = 0; i < N; i++)
	{   
		unsigned index = rand() % [sourceString length];
		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
		[result appendString:s];
	}
	return result;
}

-(void)pay{
    /*
	 *点击获取prodcut实例并初始化订单信息
	 */
	NSDictionary *goods = [[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"];
	
	/*
	 *商户的唯一的parnter和seller。
	 *本demo将parnter和seller信息存于（AlixPayDemo-Info.plist）中,外部商户可以考虑存于服务端或本地其他地方。
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */
	//如果partner和seller数据存于其他位置,请改写下面两行代码
	NSString *partner = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Partner"];
    NSString *seller = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Seller"];
	//partner和seller获取失败,提示
	if ([partner length] == 0 || [seller length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"缺少partner或者seller。" 
													   delegate:self 
											  cancelButtonTitle:@"确定" 
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
    
	/*
	 *生成订单信息及签名
	 *由于demo的局限性，本demo中的公私钥存放在AlixPayDemo-Info.plist中,外部商户可以存放在服务端或本地其他地方。
	 */
	//将商品信息赋予AlixPayOrder的成员变量
	AlixPayOrder *order = [[AlixPayOrder alloc] init];
	order.partner = partner;
	order.seller = seller;
	order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
	order.productName = [goods objectForKey:@"goods_name"]; //商品标题
	order.productDescription = [goods objectForKey:@"goods_name"]; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",[[goods objectForKey:@"promote_price"] floatValue]]; //商品价格
	order.notifyURL =  @"http://www.ucai.com"; //回调URL
	
	//应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
	NSString *appScheme = @"UCBook"; 
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
    NSLog(@"orderspec is %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"]);
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
//        orderString = [[[NSString alloc] initWithData:[Base64 decodeString:orderString] encoding:NSASCIIStringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        orderString = [[NSString alloc] initWithData:[Base64 decodeString:[orderString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] encoding:NSUTF8StringEncoding] ;
        NSLog(@"orderString is %@",orderString);
        //获取安全支付单例并调用安全支付接口
        AlixPay * alixpay = [AlixPay shared];
        int ret = [alixpay pay:orderString applicationScheme:appScheme];
        
        if (ret == kSPErrorAlipayClientNotInstalled) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                                 message:@"您还没有安装支付宝快捷支付，请先安装。" 
                                                                delegate:self 
                                                       cancelButtonTitle:@"确定" 
                                                       otherButtonTitles:nil];
            [alertView setTag:123];
            [alertView show];
        }
        else if (ret == kSPErrorSignError) {
            NSLog(@"签名错误！");
        }
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 123) {
		NSString * URLString = [NSString stringWithString:@"http://itunes.apple.com/cn/app/id535715926?mt=8"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
	}
}

- (IBAction)download:(id)sender {
    //禁用下载按钮,下载失败时设置为可用
    [self.btnOfDownload setEnabled:NO];
    if (![self isUserLogged]) {
        [self.btnOfDownload setEnabled:YES];
        return;
    }
    NSDictionary *goods = [[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"];
    if ([[goods objectForKey:@"promote_price"] doubleValue]>0) {
//    if(FALSE){
        //支付成功
        if (SharedApp.isPaySuccess) {
            [self downloadBook];
        }else {
//            [self pay];
            //1显示状态
            [SVProgressHUD show];
            //2从系统中获取一个并行队列
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //3在后台线程创建图像选择器
            dispatch_async(concurrentQueue, ^{
                CBiOSStoreManager *storeManager = [CBiOSStoreManager sharedInstance];
                [storeManager initialStore];
                [storeManager buy:[CommonUtils getIAPProductId:[goods objectForKey:@"promote_price"]]];
                [self.btnOfDownload setEnabled:YES];
                //4让主线程显示图像选择器
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];  
                });
            
            });
        }
    }else {
        [self downloadBook];
    }
}

//获取下载地址，开始下载书籍
-(void)downloadBook{
    NSDictionary *keyInfo = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfDownloadKey];
    if ([[keyInfo objectForKey:@"status"] intValue]==1) {
        self.key = [keyInfo objectForKey:@"dataInfo"];
        NSDictionary *bookDownloadInfo = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfBookDownloadPath];
        if ([[bookDownloadInfo objectForKey:@"status"] intValue]==1) {
            NSDictionary *dataInfo = [bookDownloadInfo objectForKey:@"dataInfo"];
            NSString *serverPath = [dataInfo objectForKey:@"bookpath"];
            NSArray *filePaths = [dataInfo objectForKey:@"data"];
            for (int i=0; i<[filePaths count]; i++) {
                NSString *filePath = [[filePaths objectAtIndex:i] objectForKey:@"down_path"];
                NSString *downloadUrl = [NSString stringWithFormat:@"%@%@",serverPath,filePath];
//                NSLog(@"download url is %@",downloadUrl);
                //下载书籍到本地，并完成解压操作
                [self downloadFile:downloadUrl];
                
            }
        }else {
            NSLog(@"获取下载路径失败");
            [Toast showWithText:@"书籍下载失败，请重新下载！" bottomOffset:20 duration:3];
            //恢复下载按钮
            [self.btnOfDownload setEnabled:YES];
        }
    }else {
        NSLog(@"获取下载key失败");
        [Toast showWithText:@"书籍下载失败，请重新下载！" bottomOffset:20 duration:3];
        //恢复下载按钮
        [self.btnOfDownload setEnabled:YES];
    }
}
//下载完成后更新书架上的书籍及书城列表，如果已下载标识为已下载
-(void)notifyDownMsg{
    UITabBarController *tabBarController = SharedApp.tabBarController;
    UINavigationController *first = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:0];
    BookShelfTableViewController *shelfTable = (BookShelfTableViewController *)first.visibleViewController;
    [shelfTable.tableView reloadData];
    UINavigationController *second = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:1];
    BookStoreViewController *storeViewController = (BookStoreViewController *)[second.viewControllers objectAtIndex:0];
    if (storeViewController.viewOfNewBooks!=nil) {
        [storeViewController.viewOfNewBooks reloadData];
    }
    if (storeViewController.viewOfBoutiqueBooks!=nil) {
        [storeViewController.viewOfBoutiqueBooks reloadData];
    }
    if (storeViewController.viewOfPopularityBooks!=nil) {
        [storeViewController.viewOfPopularityBooks reloadData];
    }
}

#pragma mark 下载解压相关
- (void)downloadFile:(NSString *)fileUrl
{    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:kDownloadRootPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL folderExist = [fileManager fileExistsAtPath:path];
    //文件夹不存在则创建文件夹
    if (!folderExist) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //初始化Documents路径
    NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *savefilename = [NSString stringWithFormat:@"%@%@%@%@",kDownloadRootPath,@"/",timestamp,@".zip"];
    self.downloadPath = [NSHomeDirectory() stringByAppendingPathComponent:savefilename];
    NSString *tempPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",timestamp,@".tmp"]];
    NSURL *url = [NSURL URLWithString:[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //创建请求
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;//代理
    [request setDownloadDestinationPath:self.downloadPath];//下载路径
    [request setTemporaryFileDownloadPath:tempPath];//缓存路径
    [request setAllowResumeForFileDownloads:YES];//断点续传
    request.downloadProgressDelegate = self;//下载进度代理
    self.networkQueue = [[ASINetworkQueue alloc] init];
    [self.networkQueue setShowAccurateProgress:YES];
    [self.networkQueue go];
    [self.networkQueue addOperation:request];//添加到队列，队列启动后不需重新启动
}

- (void)pauseDownload
{
    //暂停
    ASIHTTPRequest *request = [[self.networkQueue operations] objectAtIndex:0];
    [request clearDelegatesAndCancel];//取消请求
}

- (BOOL)unzipFile
{
    self.progressView.hidden = YES;
    self.lblOfDownload.hidden = NO;
    //初始化Documents路径
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:kDownloadRootPath];
    NSString *upath = [NSString stringWithFormat:@"%@%@%@",KBookSavePath,@"/",self.bookId];
    self.unzipPath = [path stringByAppendingPathComponent:upath];
    ZipArchive *unzip = [[ZipArchive alloc] init];
    if ([unzip UnzipOpenFile:self.downloadPath]) {
        BOOL result = [unzip UnzipFileTo:self.unzipPath overWrite:YES];
        if (result) {
            self.lblOfDownload.textColor = [UIColor whiteColor];
            self.lblOfDownload.text=@"已下载";
            self.lblOfDownload.backgroundColor = self.lblOfBeginRead.backgroundColor;
            [Toast showWithText:@"书籍已下载，您可以开始阅读了！" bottomOffset:20 duration:1];
            
            //下载图片到本地，书架上展现
            NSDictionary *bookDetail = [[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"];
            NSString *imgUrl = [NSString stringWithFormat:@"%@/%@/%@",[[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"imgserver"],[bookDetail objectForKey:@"shop_id"],[bookDetail objectForKey:@"goods_img"]];
            DownloadUtils *downloadUtils = [[DownloadUtils alloc] init];
            [downloadUtils downloadImage:imgUrl saveName:[bookDetail objectForKey:@"goods_img"]];
            
            NSDictionary *book = [[NSDictionary alloc] initWithObjectsAndKeys:self.bookId,@"bookId",[NSString stringWithFormat:@"/%@/%@/%@/%@",kDownloadRootPath,KBookSavePath,@"images",[bookDetail objectForKey:@"goods_img"]],@"coverUri",nil];
            //添加书籍信息
            [self.sqlUtils addLocalBook:book];
            NSDictionary *chaptersOfBook = [NSDictionary dictionaryWithContentsOfJSONURLString:kUrlOfChapterPath];
            //添加章节信息
            [self.sqlUtils addChapter:[self.bookId intValue] chapters:[chaptersOfBook objectForKey:@"dataInfo"] rootPath:[NSString stringWithFormat:@"/%@/%@",kDownloadRootPath,KBookSavePath]];
            //下载完成后更新书架上的书籍及书城列表，如果已下载标识为已下载
            [self notifyDownMsg];
            
            SharedApp.isPaySuccess = NO;
        }
        else {
            NSLog(@"解压失败1");
            [Toast showWithText:@"书籍下载失败，请重新下载！" bottomOffset:20 duration:3];
            //恢复下载按钮
            [self.btnOfDownload setEnabled:YES];
        }
        [unzip UnzipCloseFile];
        return result;
    }
    else {
        NSLog(@"解压失败2");
        [Toast showWithText:@"书籍下载失败，请重新下载！" bottomOffset:20 duration:3];
        //恢复下载按钮
        [self.btnOfDownload setEnabled:YES];
        return NO;
    }
}


- (void)deleteFile
{
    BOOL clear = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.downloadPath]) {
        if ([[NSFileManager defaultManager] removeItemAtPath:self.downloadPath error:nil]) {
            NSLog(@"删除压缩文件");
        }
        else {
            NSLog(@"删除压缩文件失败");
            clear = NO;
        }
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.unzipPath]) {
        if ([[NSFileManager defaultManager] removeItemAtPath:self.unzipPath error:nil]) {
            NSLog(@"删除解压文件");
        }
        else {
            NSLog(@"删除解压文件失败");
            clear = NO;
        }
    }
    if (clear) {
        self.fileLength = 0;
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
//    NSLog(@"收到头部！");
//    NSLog(@"%f",request.contentLength/1024.0);
//    NSLog(@"%@",responseHeaders);
    if (self.fileLength == 0) {
        self.fileLength = request.contentLength/1024.0;
        //文件总大小
//        [NSString stringWithFormat:@"%.2fKB",self.fileLength];
    }
}

- (void)setProgress:(float)newProgress
{
    //当前文件已下载大小
//    NSString *value = [NSString stringWithFormat:@"已完成%.0fKB",self.fileLength*newProgress];
//    self.lblOfDownload.text = value;
    self.progressView.progress = newProgress;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [Toast showWithText:@"书籍开始下载！" bottomOffset:20 duration:0.5];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(222, 124, 90, 25);
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 2.5)];
    self.lblOfDownload.hidden = YES;
    [self.view addSubview:self.progressView];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    [Toast showWithText:@"书籍已下载，正在解压中！" bottomOffset:80 duration:1];
//    [self performSelector:@selector(upzipFile) withObject:nil afterDelay:1];
    [self unzipFile];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [Toast showWithText:@"书籍下载失败，请重新下载！" bottomOffset:20 duration:3];
    [self deleteFile];
    //恢复下载按钮
    [self.btnOfDownload setEnabled:YES];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //书籍已下载到本地
    if ([[self.sqlUtils getLocalBookIds] containsObject:self.bookId]) {
        KDBooKViewController *bookVC = [[KDBooKViewController alloc]init];
        bookVC.bookIndex = [self.bookId intValue];
        bookVC.chapterId = [[[[[[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"] objectForKey:@"chapter"] objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:bookVC];
        navigationController.hidesBottomBarWhenPushed = YES;
        [navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentModalViewController:navigationController animated:YES];
    }else {
        //书籍没有下载到本地
        [Toast showWithText:@"请先下载书籍，再开始阅读" bottomOffset:20 duration:2];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    NSArray *chapters = [[[self.bookDetail objectForKey:@"dataInfo"] objectForKey:@"goods"] objectForKey:@"chapter"];
    if ([chapters count]<=5) {
		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
		footer.backgroundColor = [UIColor clearColor];
		return footer;
	} else {
		return nil;
	}
}
@end
