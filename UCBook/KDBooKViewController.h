#import <UIKit/UIKit.h>
#import "KDBook.h"
#import "PageView.h"
#import "SqlUtils.h"
//#import "RJBookData.h"
#import "RJBookIndexViewController.h"

@interface KDBooKViewController : UIViewController <KDBookDelegate,BookReadDelegate>{
	
	PageView  *bookLabel;	
    
	KDBook   *mBook;
	NSUInteger bookIndex;
	UISlider *bookSlider;
	UIView   *headView;
	
	NSUInteger  pageIndex;
    BOOL isNavHideflage;
    
    CGPoint gestureStartPoint;
    CGFloat currentLight;
    
    BOOL isShowIndex;
}

@property (nonatomic, readwrite)NSUInteger bookIndex;
@property (nonatomic, readwrite)NSUInteger chapterId;
@property (nonatomic, retain) SqlUtils *sqlUtils;
@property (nonatomic, copy) NSString *bookIdentify;

-(void)back:(id)sender;
-(void) ShowHideNav;
-(void) HideNav;
-(void) doBookmark;
-(void) savePlace:(NSUInteger) nPage;
-(void) showPage;

//toolbar的响应事件
-(void) doPre;
-(void) doFont;
-(void) doColor;
-(void) doNext;
-(void) doIndex;

@end
