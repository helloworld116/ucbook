//
//  NSDictionary+JSONCategories.m
//  ShopCloth
//
//  Created by apple on 12-12-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+JSONCategories.h"

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
//    NSLog(@"the request url is %@",urlAddress);
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    //过滤回车换行
    NSString *respone = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    respone = [respone stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    data = [respone dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return nil;
    }
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data 
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self 
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

