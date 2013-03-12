//
//  BookCharacterTableView.m
//  UCBook
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BookCharacterTableView.h"
#import "NSDictionary+JSONCategories.h"
#import "ReadBooks.h"
#import "CommonUtils.h"

@interface BookCharacterTableView()
@property (nonatomic,copy) NSString *key;
@end

@implementation BookCharacterTableView
@synthesize characters=_characters;
@synthesize key=_key;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSource = self;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.    
    return [self.characters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bookCharacterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)  
    {  
        // Create a cell to display an ingredient.  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle   
                                      reuseIdentifier:CellIdentifier];  
    }  
    // Configure the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    cell.textLabel.text = [[self.characters objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 85.f;
//}
@end
