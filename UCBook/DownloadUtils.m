//
//  DownloadUtils.m
//  UCBook
//
//  Created by apple on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "DownloadUtils.h"
#import "AppDelegate.h"
@interface DownloadUtils()
@property (nonatomic,retain) ASIHTTPRequest *request;
@end

@implementation DownloadUtils
@synthesize request;


- (void) cancelDownload {
    [self.request cancel];
    self.request = nil;
}

- (void) downloadImage:(NSString *)imageURL  saveName:(NSString *)name{
    [self cancelDownload];
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:kDownloadRootPath] stringByAppendingPathComponent:KBookSavePath] stringByAppendingPathComponent:@"images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL folderExist = [fileManager fileExistsAtPath:path];
    //文件夹不存在则创建文件夹
    if (!folderExist) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
	NSString *newImageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *imageSaveDetail = [NSString stringWithFormat:@"%@/%@",path,name];
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:newImageURL]];
    [self.request setDownloadDestinationPath:imageSaveDetail];
    [self.request setDelegate:self];
    [self.request setCompletionBlock:^(void){
        self.request.delegate = nil;
        self.request = nil;
        NSLog(@"image is download");
    }];
    [self.request setFailedBlock:^(void){
        [self.request cancel];
        self.request.delegate = nil;        
        self.request = nil;
        NSLog(@"image download failed");
    }];
    [self.request startAsynchronous];
}

@end
