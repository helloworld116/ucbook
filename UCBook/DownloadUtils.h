//
//  DownloadUtils.h
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface DownloadUtils : NSObject
- (void) downloadImage:(NSString *)imageURL saveName:(NSString *)name;
@end
