//
//  BookStoreTableCell.h
//  UCBook
//
//  Created by apple on 13-1-11.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "StrikeLabel.h"

@interface BookStoreTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet AsyncImageView *imgViewOfFrontConver;
@property (strong, nonatomic) IBOutlet UILabel *lblOfName;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewOfDownload;

@property (strong, nonatomic) IBOutlet StrikeLabel *lblOfOriginalPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblOfCurrentPrice;

@property (strong, nonatomic) IBOutlet UILabel *lblOfClickCount;
@end
