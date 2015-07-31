//
//  DetailInfoViewController.h
//  PersonalInfo
//
//  Created by charles on 4/29/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "CommonTableViewController.h"
#import "TLUser.h"

typedef enum {
    FromList,//来自通讯录,发起会话
    FromSearch,//好友搜索,加为好友
    FromSelf//
}DetailInfoType;//枚举名称

@interface DetailInfoViewController : CommonTableViewController <UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic)TLUser *friendInfo;
@property (nonatomic)DetailInfoType type;

+ (DetailInfoViewController *) getDetailVC;

@end
