#import "loadMoreCell.h"


@implementation LoadMoreCell

@synthesize loadMoreSpinner, loadMoreLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.clearsContextBeforeDrawing = YES;
        self.contentView.backgroundColor = [UIColor clearColor]; //UIColorFromHex(0x333333);
        self.backgroundColor = [UIColor clearColor]; //UIColorFromHex(0x222222);
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor]; //UIColorFromHex(0xff0000);
        
        CGRect contentRect = self.bounds;
        
//        CGRect bgRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height);   
//        UIImageView* imgview = [[UIImageView alloc] initWithFrame: bgRect];
//        UIImage* cellbg = [UIImage imageNamed:@"pdcellbgselected.png"];
//        imgview.image = cellbg;
//        self.backgroundView = imgview;
//        
//        UIImageView* imgviewsel = [[UIImageView alloc] initWithFrame: bgRect];
//        UIImage* cellbgsel = [UIImage imageNamed:@"pdcellbg.png"];
//        imgviewsel.image = cellbgsel;
//        self.selectedBackgroundView = imgviewsel;       
        
        //make a label that says load more and add it
        loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadMoreLabel.clearsContextBeforeDrawing = YES;
        loadMoreLabel.backgroundColor = [UIColor clearColor];
        loadMoreLabel.opaque = YES;
        loadMoreLabel.textColor = [UIColor whiteColor];
        loadMoreLabel.highlightedTextColor = [UIColor whiteColor];
        loadMoreLabel.numberOfLines = 0;
        loadMoreLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        loadMoreLabel.shadowColor = [UIColor blackColor];
        loadMoreLabel.textAlignment = UITextAlignmentLeft;
        loadMoreLabel.text = @"Load More";
        loadMoreLabel.frame = CGRectMake(contentRect.origin.x + 77, contentRect.origin.y, 200, 50);
        
        [self.contentView addSubview:self.loadMoreLabel];
        
        //add a spinner that stays hidden til we need it
        loadMoreSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        loadMoreSpinner.hidden = NO;
        loadMoreSpinner.opaque = YES;
        loadMoreSpinner.clearsContextBeforeDrawing = YES;
        loadMoreSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        loadMoreSpinner.frame = CGRectMake(contentRect.origin.x + 28, contentRect.origin.y + 13, 20, 20);
        loadMoreSpinner.hidesWhenStopped = YES;
        [loadMoreSpinner stopAnimating];
        
        [self.contentView addSubview:self.loadMoreSpinner];
    }
    return self;
}

- (void)showSpinner{
    [loadMoreSpinner startAnimating];       
    [loadMoreSpinner setHidden:NO];
}
- (void)hideSpinner{
    [loadMoreSpinner setHidden:YES];
    [loadMoreSpinner stopAnimating];        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end