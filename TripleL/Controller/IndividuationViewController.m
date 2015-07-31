//
//  IndividuationViewController.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/20.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "IndividuationViewController.h"
#import "CommonTableViewCell.h"
#import "MyHeader.h"

#import "FontStyleViewController.h"
#import "ColorStyleViewController.h"
#import "PuppleStyleViewController.h"

@interface IndividuationViewController ()
{
    NSMutableArray *data;
}

@property (nonatomic, strong) FontStyleViewController *fontStyleVC;
@property (nonatomic, strong) ColorStyleViewController *colorStyleVC;
@property (nonatomic, strong) PuppleStyleViewController *puppleStyleVC;

@end

@implementation IndividuationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"个性化设置"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"individuation" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    if ([type isEqualToString:@"normal"]) {
        NSString *title = [dic objectForKey:@"title"];
        cell.textLabel.text = title;
        [cell setUserInteractionEnabled:YES];
    }
    else if([type isEqualToString:@"empty"]){
        cell.textLabel.text = @"";
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else if([type isEqualToString:@"explanation"]){
        UITextView *textView = [[UITextView alloc] init];
        textView.text = [dic objectForKey:@"title"];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT);
        CGSize size = [textView sizeThatFits:constraintSize];
        [textView setFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, size.height + 20)];
        textView.textColor = [UIColor grayColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont systemFontOfSize:13];
        textView.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:textView];
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    if ([dic objectForKey:@"withDetail"] != nil) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if ([dic objectForKey:@"withoutLine"] != nil){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0,0, self.view.frame.size.width / 2.0)];
    }
    
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"字体方案"]) {
        int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
        NSDictionary *dic = [[AppConfig getFontStyleArray] objectAtIndex:choose];
        [cell.detailTextLabel setText: [dic objectForKey:@"title"]];
    }
    else if ([title isEqualToString:@"配色方案"]){
        int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
        NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
        [cell.detailTextLabel setText: [dic objectForKey:@"title"]];
    }
    else if ([title isEqualToString:@"气泡设置"]){
       int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"puppleStyle"]).intValue;
        NSDictionary *dic = [[AppConfig getPuppleStyleArray] objectAtIndex:choose];
        [cell.detailTextLabel setText: [dic objectForKey:@"title"]];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"normal"]){
        return 45;
    }
    else if ([type isEqualToString:@"empty"]){
        return 20;
    }
    else if ([type isEqualToString:@"explanation"]){
        UITextView *textView = [[UITextView alloc] init];
        textView.text = [dic objectForKey:@"title"];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT);
        CGSize size = [textView sizeThatFits:constraintSize];
        return size.height;
    }
    
    return 30;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"字体方案"]) {
        if (_fontStyleVC == nil) {
            _fontStyleVC = [[FontStyleViewController alloc] init];
        }
        [self.navigationController pushViewController:_fontStyleVC animated:YES];
    }
    else if ([title isEqualToString:@"配色方案"]){
        if (_colorStyleVC == nil) {
            _colorStyleVC = [[ColorStyleViewController alloc] init];
        }
        [self.navigationController pushViewController:_colorStyleVC animated:YES];
    }
    else if ([title isEqualToString:@"气泡设置"]){
        if (_puppleStyleVC == nil) {
            _puppleStyleVC = [[PuppleStyleViewController alloc] init];
        }
        [self.navigationController pushViewController:_puppleStyleVC animated:YES];
    }
    
    [self.tableView reloadData];
}

@end
