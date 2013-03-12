//
//  BookStoreTableCell.m
//  UCBook
//
//  Created by apple on 13-1-11.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BookStoreTableCell.h"

@implementation BookStoreTableCell
@synthesize imgViewOfFrontConver=_imgViewOfFrontConver;
@synthesize lblOfName=_lblOfName;
@synthesize imgViewOfDownload=_imgViewOfDownload;
@synthesize lblOfCurrentPrice=_lblOfCurrentPrice;
@synthesize lblOfOriginalPrice=_lblOfOriginalPrice;
@synthesize lblOfClickCount=_lblOfClickCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.lblOfOriginalPrice setStrikeThroughEnabled:YES];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
