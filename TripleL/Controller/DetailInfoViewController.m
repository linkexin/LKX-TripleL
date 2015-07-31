//
//  DetailInfoViewController.m
//  PersonalInfo
//
//  Created by charles on 4/29/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "FriendsListViewController.h"
#import "DetailInfoViewController.h"
#import "DetailDataCell.h"
#import "DetailInfoCenter.h"
#import "ModifyInfoViewController.h"

#import "MyHeader.h"
#import "LoadindView.h"
#import "MBProgressHUD.h"
#import "ChatViewController.h"
#import "UIImageView+WebCache.h"
#import "SCLAlertView.h"
#import "FirstCell.h"

#define FONT_SIZE 17.0f
#define CELL_CONTENT_WIDTH self.view.frame.size.width * 0.6
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DETAIL_X self.view.frame.size.width * 0.35
#define CELL_TITLE_X self.view.frame.size.width * 0.25

static DetailInfoViewController *detailVC = nil;

@interface DetailInfoViewController ()
{
    NSMutableArray *title;
    NSMutableArray *items;
    NSMutableArray *indexName;
    NSString *errorInfo;
    TLUser *friendDetailInfo;
    TLUser *myInfo;
    UITextView *textView;
}

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *btnNextPage;

@end

@implementation DetailInfoViewController

+ (DetailInfoViewController *) getDetailVC
{
    if (detailVC == nil) {
        detailVC = [[DetailInfoViewController alloc] init];
    }
    return detailVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    title = [[NSMutableArray alloc]init];
    items = [[NSMutableArray alloc]init];
    indexName = [[NSMutableArray alloc]init];
    textView = [[UITextView alloc] init];
    [textView setFont:[UIFont systemFontOfSize:18]];
    
    [[DetailInfoCenter getDetailInfoCenter] initFriendInfo];
    
    _footerView = [[UIView alloc] init];
    _footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = _footerView;
    
    _btnNextPage = [[UIButton alloc]init];
    [_btnNextPage addTarget:self action:@selector(startChat) forControlEvents:UIControlEventTouchUpInside];
    [_btnNextPage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnNextPage.backgroundColor = [AppConfig getStatusBarColor];
    _btnNextPage.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavTitle:@"详细信息"];
    
    [self.tabBarController.tabBar setHidden:YES];
    self.navigationItem.rightBarButtonItem = nil;
    
    if(_type == FromSelf)
    {
        UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(SelfMoreButtonDown)];
        self.navigationItem.rightBarButtonItem = myCoolButton;
    }
    else if(_type == FromList)
    {
        UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStyleDone target:self action:@selector(FriendMoreButtonDown)];
        self.navigationItem.rightBarButtonItem = myCoolButton;
        [_btnNextPage setTitle:@"发起会话" forState: UIControlStateNormal];
    }
    else if(_type == FromSearch)
    {
        //self.navigationItem.rightBarButtonItem = nil;
        [_btnNextPage setTitle:@"加为好友" forState: UIControlStateNormal];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDetailInfo:) name:INFO_GETDETAILINFOSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDetailFailed:) name:INFO_GETDETAILINFOFAILED object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (remarkNameModifysueccessful) name:INFO_MODIFYREMARKNAMESUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (remarkNameModifyfailed:) name:INFO_MODIFYREMARKNAMEFAILED object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (deleteFriendsueccessful) name:INFO_DELETEFRIENDSUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (deleteFriendfailed:) name:INFO_DELETEFRIENDFAILED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    
    [self initdata];
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
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"请求数据失败，请检查网络！" closeButtonTitle:nil duration:0.0f];
}

-(void)initdata
{
    if(_type == FromSelf)
        _friendInfo = [[MyServer getServer]getSelfAccountInfo];
    
    errorInfo = nil;
    
    [[MyServer getServer]getUserAccountDetailedInfoByUsername:_friendInfo.username];
    
    [title removeAllObjects];
    [items removeAllObjects];
    NSMutableArray *temp = [DetailInfoCenter getDetailInfoCenter].friendArr;
    for(int i = 0; i < 5; i++)
    {
        [title addObject:[[temp objectAtIndex:i] objectForKey:@"title"]];
        //[items addObject:[[temp objectAtIndex:i] objectForKey:@"content"]];
        [indexName addObject:[[temp objectAtIndex:i] objectForKey:@"name"]];
    }
    //[items addObject:_friendInfo.avatar];
    [items addObject:_friendInfo.username];
    _friendInfo.nickname != nil ? [items addObject:_friendInfo.nickname] : [items addObject:@""];
    if(_type != FromSelf && _friendInfo.age != nil)
        [items addObject:_friendInfo.age];
    else
        [items addObject:@""];

    _friendInfo.mood != nil ? [items addObject:_friendInfo.mood] : [items addObject:@""];
    
    [self showInfo];
}

#pragma mark-Notifacation
-(void)receivedDetailInfo:(NSNotification *)notification
{
    friendDetailInfo = notification.object;
    if([friendDetailInfo.username isEqualToString: myInfo.username])
        _type = FromSelf;
    
    
    [title removeAllObjects];
    [items removeAllObjects];
    NSMutableArray *temp = [DetailInfoCenter getDetailInfoCenter].friendArr;
    for(int i = 0; i < 5; i++)
        [title addObject:[[temp objectAtIndex:i] objectForKey:@"title"]];
    
    [items addObject:@""];
    [items addObject:friendDetailInfo.nickname];
    [items addObject:friendDetailInfo.age];
    [items addObject:friendDetailInfo.constellation];
    [items addObject:friendDetailInfo.mood];
    
    
    if(![friendDetailInfo.emotionCondition isKindOfClass: [NSNull class]] && ![friendDetailInfo.emotionCondition isEqualToString:@""])
    {
        [title addObject:@"情感状况"];
        [items addObject:friendDetailInfo.emotionCondition];
    }
    
    if(![friendDetailInfo.hometown isKindOfClass: [NSNull class]] && ![friendDetailInfo.hometown isEqualToString:@""])
    {
        [title addObject:@"家乡"];
        [items addObject:friendDetailInfo.hometown];
    }
    
    if(![friendDetailInfo.location isKindOfClass: [NSNull class]] && ![friendDetailInfo.location isEqualToString:@""])
    {
        [title addObject:@"所在地"];
        [items addObject:friendDetailInfo.location];
    }
    
    if(![friendDetailInfo.company isKindOfClass: [NSNull class]] && ![friendDetailInfo.company isEqualToString:@""])
    {
        [title addObject:@"公司"];
        [items addObject:friendDetailInfo.company];
    }
    
    if(![friendDetailInfo.school isKindOfClass: [NSNull class]] && ![friendDetailInfo.school isEqualToString:@""])
    {
        [title addObject:@"学校"];
        [items addObject:friendDetailInfo.school];
    }
    
    if(![friendDetailInfo.career isKindOfClass: [NSNull class]] && ![friendDetailInfo.career isEqualToString:@""])
    {
        [title addObject:@"职业/专业"];
        [items addObject:friendDetailInfo.career];
    }
    
    if(![friendDetailInfo.createTime isKindOfClass: [NSNull class]])
    {
        [title addObject:@"注册时间"];
        
        double lastactivityInterval = [friendDetailInfo.createTime doubleValue] / 1000;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:lastactivityInterval];
        NSString* dateString = [formatter stringFromDate:date];
        [items addObject:dateString];
    }
    [title addObject:@""];//最后的按钮
    [items addObject:@""];
    
    [self.tableView reloadData];
}

//广播响应函数
-(void)receivedDetailFailed:(NSNotification *)notification
{
    NSLog(@"notification failed");
    errorInfo = notification.object;
    [self showInfo];
}

-(void)remarkNameModifysueccessful
{
    [self initdata];
}

-(void)remarkNameModifyfailed:(NSNotification *)noti
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"备注修改失败";
    hud.detailsLabelText = noti.object;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

-(void)deleteFriendsueccessful
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteFriendfailed:(NSNotification *) noti
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"删除好友失败";
    hud.detailsLabelText = noti.object;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

#pragma mark-
-(void)showInfo
{
    if(errorInfo != nil)
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
        [hud setLabelText:errorInfo];
        [hud show:YES];
        [hud hide:YES afterDelay:2];
        [self.tabBarController.tabBar setHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.tableView reloadData];
    }
}

#pragma UItableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_type == FromSelf)
        return [title count] - 1;
    else
        return [title count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        FirstCell *firstcell = [[FirstCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        
        BOOL isSelf;
        if(_type == FromSelf)
            isSelf = YES;
        else
            isSelf = NO;
        
        [firstcell SetTableViewWithAvatar:friendDetailInfo.avatar username:friendDetailInfo.username remarkName:friendDetailInfo.remarkName gender:friendDetailInfo.gender star:3 isSelf:isSelf];
        [firstcell setBackgroundColor:[AppConfig getFGColor]];
        firstcell.userInteractionEnabled = NO;
        return firstcell;
    }
    
    if(indexPath.row == [title count] - 1 && (_type != FromSelf))
    {
        UITableViewCell *btcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [btcell setBackgroundColor:[UIColor clearColor]];
        _btnNextPage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.05, 20, [UIScreen mainScreen].bounds.size.width * 0.9, 37);
        [btcell addSubview:_btnNextPage];
        [btcell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0, 0, self.view.frame.size.width / 2.0)];
        return btcell;
    }
    
    textView.text = [NSString stringWithFormat:@"%@",items[indexPath.row]];
    CGSize constraint = CGSizeMake(self.view.frame.size.width * 0.6, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraint];
    DetailDataCell *cell = [[DetailDataCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, size.height + 8)];
    cell.titleTextView.userInteractionEnabled = NO;
    cell.detailTextView.userInteractionEnabled = NO;
    [cell setupCellwithTitle:title[indexPath.row] detail:items[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == [title count] - 1)//头像和按钮
        return 100;
    
    NSString *text = [items objectAtIndex:[indexPath row]];
    textView.text = [NSString stringWithFormat:@"%@",text];
    CGSize constraint = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.6, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraint];
    return size.height + 8;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
}


#pragma mark -Delegate

-(void)startChat
{
    if(_type == FromList)
    {
        [self.navigationController popViewControllerAnimated:NO];
        ChatViewController *chatVC = [ChatViewController getChatViewController];
        chatVC.selfUser = [[MyServer getServer] getSelfAccountInfo];
        chatVC.friendUser = self.friendInfo;
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SHOWCHATVC object:nil];
    }
    else
    {
//        if(friendDetailInfo.gameInfo.addFriendWay == 0)
//        {
//            [[MyServer getServer]addFriendByUsername:friendDetailInfo.username andMessage:@""];
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = @"请求已发送";
//            hud.margin = 10.f;
//            hud.removeFromSuperViewOnHide = YES;
//            
//            [hud hide:YES afterDelay:1.5];
//            [self performSelector:@selector(popView) withObject:nil afterDelay:2.0f];
//        }
//        else
//        {
            SCLAlertView *alertView = [[SCLAlertView alloc] init];
            UITextField *textField = [alertView addTextField:@"请输入验证信息"];
            [alertView addButton:@"发送" actionBlock:^{
                [[MyServer getServer]addFriendByUsername:_friendInfo.username andMessage:textField.text];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
                hud.mode = MBProgressHUDModeAnnularDeterminate;
                hud.labelText = @"请求已发送";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:1.5];
                [self performSelector:@selector(popView) withObject:nil afterDelay:2.0f];
            }];
            [alertView showEdit:self.tabBarController title:@"好友申请" subTitle:@"请输入好友验证信息：" closeButtonTitle:@"取消" duration:0];
//        }
    }
}

-(void)popView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)SelfMoreButtonDown
{
    ModifyInfoViewController *modefyInfoView = [[ModifyInfoViewController alloc]init];
    [DetailInfoCenter getDetailInfoCenter].selfInfo = friendDetailInfo;
    [self.navigationController pushViewController:modefyInfoView animated: YES];
}

-(void)FriendMoreButtonDown
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"删除好友"
                                                   otherButtonTitles:@"修改备注",nil];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
}


#pragma UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0)
    {
        switch (buttonIndex)
        {
            case 0://删除好友
            {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                alert.view.layer.zPosition = 10;
                [alert addButton:@"确定" actionBlock:^{
                    [[ MyServer getServer]deleteFriendByUsername:friendDetailInfo.username];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert showWarning:self.tabBarController title:@"确定要删除好友吗" subTitle:@"删除好友同时会将我从对方列表中删除，并不再接收此人的信息" closeButtonTitle:@"取消" duration:0.0f];
            }
                break;
            case 1:
            {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                alert.view.layer.zPosition = 10;
                UITextField *remarkName = [alert addTextField:@"备注名"];
                [alert addButton:@"确定" actionBlock:^{
                    NSString *name = remarkName.text;
                    if(![name isEqualToString:@""])
                    {
                        [[MyServer getServer]modifyRemarkName:name toUser:friendDetailInfo.username];
                        //[self initdata];
                    }
                }];
                
                [alert showEdit:self.tabBarController title:@"修改" subTitle:@"请输入备注名" closeButtonTitle:@"取消" duration:0];
            }
                break;
            default://取消
                break;
        }
    }
}


@end
