//
//  BookCharacterTableView.h
//  UCBook
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCharacterTableView : UITableView<UITableViewDataSource>

@property (nonatomic,retain) NSMutableArray *characters;

@end
