//
//  BookDetailViewController.h
//  UCBook
//
//  Created by apple on 12-12-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "BookCharacterTableView.h"
#import "StrikeLabel.h"
#import "LoginViewController.h"
#import "CommentTableView.h"

@interface BookDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet AsyncImageView *imgViewOfBookCover;
@property (strong, nonatomic) IBOutlet UILabel *lblBookName;
@property (strong, nonatomic) IBOutlet UILabel *lblAuthor;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet StrikeLabel *lblOriginalPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblWordCount;
@property (strong, nonatomic) IBOutlet UILabel *lblOfBeginRead;
@property (strong, nonatomic) IBOutlet UILabel *lblOfDownload;
@property (strong, nonatomic) IBOutlet UIButton *btnOfBeginRead;
@property (strong, nonatomic) IBOutlet UIButton *btnOfDownload;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UIScrollView *svContainer;
@property (strong, nonatomic) UIWebView *webViewIntr;
@property (strong, nonatomic) BookCharacterTableView *tableViewChara;
@property (strong, nonatomic) CommentTableView *tableViewComment;
- (IBAction)beginRead:(id)sender;
- (IBAction)download:(id)sender;

@property (nonatomic, retain) NSString* bookId;
@property (nonatomic, retain) NSDictionary *bookDetail;
@end
