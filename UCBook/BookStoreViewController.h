//
//  BookStoreViewController.h
//  UCBook
//
//  Created by apple on 12-12-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookStoreView.h"

@interface BookStoreViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *svContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segcontol;

@property (strong, nonatomic) BookStoreView *viewOfNewBooks,*viewOfBoutiqueBooks,*viewOfPopularityBooks;

@end
