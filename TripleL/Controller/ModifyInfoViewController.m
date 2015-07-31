//
//  ModifyInfoViewController.m
//  TripleL
//
//  Created by charles on 5/15/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyInfoViewController.h"
#import "ModifyInfoCell.h"
#import "SCLAlertView.h"
#import "MyHeader.h"
#import "MBProgressHUD.h"
#import "DetailInfoCenter.h"
#import "ModifyBaseViewController.h"

#define CELL_CONTENT_WIDTH self.view.frame.size.width * 0.6
#define CELL_CONTENT_MARGIN 5.0f
#define CELL_DETAIL_X self.view.frame.size.width * 0.35
#define CELL_TITLE_X self.view.frame.size.width * 0.25

@interface ModifyInfoViewController()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    UITextView *textView;
    NSMutableArray *content;
    TLUser *selfInfo;
}

@end

@implementation ModifyInfoViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"编辑详细信息"];
    
    textView = [[UITextView alloc]init];
    textView.font = [UIFont systemFontOfSize:18];
    textView.backgroundColor = [UIColor clearColor];//设置它的背景颜色
    
    UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(completeDown)];
    self.navigationItem.rightBarButtonItem = myCoolButton;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backDown)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    [[DetailInfoCenter getDetailInfoCenter]initself];
    [self initData];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setTableFooterView:view];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (uploadPhotoSuccessful:) name:INFO_UPLOADIMAGESUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPhotoFailed:) name:INFO_UPLOADIMAGEFAILDE object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifySelfInfo:) name:INFO_MODIFYSELFINFO object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) networkAnomaly
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"请求数据失败，请检查网络！" closeButtonTitle:@"确定" duration:0.0f];
}

-(void)initData
{
    [[DetailInfoCenter getDetailInfoCenter].content removeAllObjects];
    selfInfo = [DetailInfoCenter getDetailInfoCenter].selfInfo;
    if (selfInfo == nil || selfInfo.username == nil) {
        return;
    }
    [DetailInfoCenter getDetailInfoCenter].username = selfInfo.username;
    [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.nickname];
    [[DetailInfoCenter getDetailInfoCenter].content addObject:[NSString stringWithFormat:@"%@", selfInfo.age]];
    [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.constellation];
    [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    if([selfInfo.mood isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.mood];
    
    if([selfInfo.emotionCondition isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.emotionCondition];
    
    if([selfInfo.hometown isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.hometown];
    
    if([selfInfo.location isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.location];
    

        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    
    if([selfInfo.company isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.company];
    
    if([selfInfo.school isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.school];
    
    if([selfInfo.career isKindOfClass:[NSNull class]])
        [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
    else
        [[DetailInfoCenter getDetailInfoCenter].content addObject:selfInfo.career];
    
    [[DetailInfoCenter getDetailInfoCenter].content addObject:@""];
        
    //for(int i = 0; i < [[DetailInfoCenter getDetailInfoCenter].content count]; i++)
        //NSLog(@"%@", [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:i]);
}


#pragma mark - tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DetailInfoCenter getDetailInfoCenter].content count] - 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    static NSString *identifier = @"modifyInfoCell";
    
    ModifyInfoCell *cell = [[ModifyInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.textLabel.text = @"";
    cell.imageView.image = nil;
    
    if (![title isEqualToString:@""]) {
        
        CGSize constraint = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.6, MAXFLOAT);
        textView.text = [NSString stringWithFormat:@"%@",[[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:indexPath.row]];
        CGSize size = [textView sizeThatFits:constraint];
        
        CGFloat height = size.height;
        if(indexPath.row == 0)
        {
            height = 55;
            [cell setCellWithtitle:title andinfo: [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:indexPath.row] titlelocation:CGRectMake(CELL_CONTENT_MARGIN, 0, [UIScreen mainScreen].bounds.size.width * 0.25, height) infolocation:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.35 , 10, [UIScreen mainScreen].bounds.size.width * 0.6, height - 10)];
        }
        else
            [cell setCellWithtitle:title andinfo: [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:indexPath.row] titlelocation:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, [UIScreen mainScreen].bounds.size.width * 0.25, height) infolocation:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.35 , CELL_CONTENT_MARGIN, [UIScreen mainScreen].bounds.size.width * 0.6, height)];
        [cell setUserInteractionEnabled:YES];
    }
    else
    {
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    if(indexPath.row == 0)
    {
        [cell addPhoto:selfInfo.avatar local:[DetailInfoCenter getDetailInfoCenter].avater withRect:CGRectMake(0, 0, 40, 40)];
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if(indexPath.row == 0)
        return 55;
    if (![title isEqualToString:@""])
    {
        CGSize constraint = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.6, MAXFLOAT);
        
        textView.text = [NSString stringWithFormat:@"%@",[[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:indexPath.row]];
        CGSize size = [textView sizeThatFits:constraint];
        return size.height + 8;
    }
    
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:indexPath.row];
    
    NSString *className = [dic objectForKey:@"jumpto"];
    
    ModifyBaseViewController *subViewController = [[NSClassFromString(className) alloc] init];
    subViewController.index = (int)indexPath.row;
    
    [self.navigationController pushViewController:subViewController animated:YES];
}

-(void)completeDown
{
    [[DetailInfoCenter getDetailInfoCenter]completeModifySelfInfo];
}

-(void)backDown
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"放弃修改" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showNotice:self.tabBarController title:@"取消" subTitle:@"修改尚未提交，确定要放弃吗？" closeButtonTitle:@"继续编辑" duration:0.0f];
}

#pragma  mark-
//广播响应函数
-(void)uploadPhotoSuccessful: (NSNotification*)notification
{
    NSLog(@"update photo success");
    [DetailInfoCenter getDetailInfoCenter].avater = notification.object;
    [DetailInfoCenter getDetailInfoCenter].selfInfo.avatar = notification.object;
    [self.tableView reloadData];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *username = [user objectForKey:@"username"];
    NSString *passWord = [user objectForKey:@"psword"];
    //[[MyServer getServer] logout];
    [[MyServer getServer] loginWithUsername: username andPassword: passWord];
}


-(void)uploadPhotoFailed:(NSNotification *)notification
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"头像上传失败:(";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

-(void)modifySelfInfo:(NSNotification *)notifacation
{
    if([notifacation.object isEqualToString:@""])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"请再试一次";
        hud.labelText = @"资料更新失败:(";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:3];
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
