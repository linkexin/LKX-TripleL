//
//  ImageUploadViewController.m
//  toFace
//
//  Created by charles on 4/12/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "ImageUploadViewController.h"
#import "MyHeader.h"
#import "UITextField+Shake.h"
#import "RegisterViewController.h"
#import "MyServer.h"
#import "MenuViewController.h"
#import "XTSideMenu.h"
#import "RootViewController.h"

#define LOCX_SPRITE self.view.frame.size.width * 0.1
#define WIDTH_SPRITE self.view.frame.size.width * 0.8
#define LEFT_PHOTO_RECT CGRectMake(0, 2.5, 50, 35)

@interface ImageUploadViewController()
{
    bool isSelectGender;
    bool isSelectBirth;
    bool isSelectPhoto;
    bool isUploadPhoto;
    bool isRegisterSuccessful;
    
    
    NSString *userName;
    NSString *nickName;
    NSString *psWord;
    NSString *gender;
    NSString *photoPath;
    NSString *networkPath;
    NSString *birthDay;
}
@end


@implementation ImageUploadViewController
@synthesize bgView;

-(void)viewDidLoad
{
    isSelectBirth = false;
    isSelectGender = false;
    isSelectPhoto = false;
    isRegisterSuccessful = false;
    isUploadPhoto = false;
    
    bgView = [[UIImageView alloc]init];
    if([UIDevice deviceVerType] == DeviceVer4)
        bgView.image =[UIImage imageNamed:@"background4S2.jpg"];
    else
        bgView.image =[UIImage imageNamed:@"background2.jpg"];
    //bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    [bgView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgView.contentMode = UIViewContentModeScaleAspectFit;
    bgView.userInteractionEnabled = YES;
    [self.view addSubview: bgView];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
    _effectview = [[UIVisualEffectView alloc] initWithEffect: blur];
    _effectview.frame = CGRectMake(0,0, bgView.frame.size.width, bgView.frame.size.height);
    [bgView addSubview: _effectview];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    label.text = @"设置基本信息";
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.0/255.0 green:138.0/255.0 blue:255.0/255.0 alpha:1.0];
    label.textColor = [UIColor blackColor];
    [self.navigationItem setTitleView:label];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"上一步" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backItem setTintColor:[UIColor grayColor]];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    
    _selectIconButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.35, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.3)];
    [_selectIconButton.layer setCornerRadius: _selectIconButton.frame.size.height / 2];
    _selectIconButton.backgroundColor = [UIColor colorWithRed:173 green:216 blue:230 alpha:0.4];
    [_selectIconButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectIconButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _selectIconButton.titleLabel.font = [UIFont systemFontOfSize:15];
    //[_selectIconButton setTitle:@"Update Photo" forState: UIControlStateNormal];
    _selectIconButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 10);
    _profilePhoto= [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectIcon.png"]];
    [_profilePhoto setFrame: CGRectMake(_selectIconButton.frame.size.width / 4, _selectIconButton.frame.size.width / 4, _selectIconButton.frame.size.width / 2, _selectIconButton.frame.size.width / 2)];
    [_selectIconButton addSubview:_profilePhoto];
    [_selectIconButton addTarget:self action:@selector(selectIconButtonDown) forControlEvents:UIControlEventTouchUpInside];
    _selectIconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _selectIconButton.userInteractionEnabled = YES;
    
    
    _selectGenderButton = [[UIButton alloc]initWithFrame: CGRectMake(LOCX_SPRITE, _selectIconButton.frame.origin.y + _selectIconButton.frame.size.height + 30, WIDTH_SPRITE, 40)];
    _selectGenderButton.backgroundColor = DEFAULT_INPUT_COLOR;//[UIColor redColor];
    _selectGenderButton.alpha = 0.5;
    [_selectGenderButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    _selectGenderButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_selectGenderButton setTitle:@"      点击选择性别(保存后不能修改)" forState:UIControlStateNormal];
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectGender.png"]];
    [img setFrame: LEFT_PHOTO_RECT];
    img.alpha = 1;
    [_selectGenderButton addSubview:img];
    [_selectGenderButton addTarget:self action:@selector(selectGenderButtonDown) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _selectBirthButton = [[UIButton alloc]initWithFrame: CGRectMake(LOCX_SPRITE, _selectGenderButton.frame.origin.y + _selectGenderButton.frame.size.height + 1, WIDTH_SPRITE, 40)];
    _selectBirthButton.backgroundColor = DEFAULT_INPUT_COLOR;
    _selectBirthButton.alpha = 0.5;
    [_selectBirthButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    _selectBirthButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_selectBirthButton setTitle:@"      点击选择生日" forState:UIControlStateNormal];
    UIImageView *img1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"seleteBirth.png"]];
    [img1 setFrame: LEFT_PHOTO_RECT];
    img1.alpha = 1;
    [_selectBirthButton addSubview:img1];
    [_selectBirthButton addTarget:self action:@selector(selectBirthButtonDown) forControlEvents:UIControlEventTouchUpInside];
    
    
    _errorInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _selectBirthButton.frame.origin.y + 41, WIDTH_SPRITE, 35)];
    _errorInfoLabel.text = @"";
    _errorInfoLabel.backgroundColor = [UIColor redColor];
    _errorInfoLabel.alpha = 0.5;
    _errorInfoLabel.font = [UIFont boldSystemFontOfSize:13];
    _errorInfoLabel.textAlignment = NSTextAlignmentCenter;
    _errorInfoLabel.textColor = [UIColor whiteColor];

    
    _completeButton = [[UIButton alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _errorInfoLabel.frame.origin.y + 50, WIDTH_SPRITE, 40)];
    _completeButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:128 alpha:0.3];
    [_completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_completeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_completeButton setTitle:@"完成" forState: UIControlStateNormal];
    [_completeButton addTarget:self action:@selector(completeButtonDown) forControlEvents:UIControlEventTouchUpInside];
    _completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _completeButton.userInteractionEnabled = YES;

    
    [bgView addSubview: _errorInfoLabel];
    _errorInfoLabel.hidden = YES;
    [bgView addSubview: _selectBirthButton];
    [bgView addSubview: _selectGenderButton];
    [bgView addSubview: _selectIconButton];
    [bgView addSubview: _completeButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //接收广播
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (uploadPhotoSuccessful:) name:INFO_UPLOADIMAGESUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPhotoFailed:) name:INFO_UPLOADIMAGEFAILDE object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (registerSuccessful) name:INFO_REGSTERSUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (registerFailed:) name:INFO_REGISTERFAILED object: nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)getinfowith: (NSString *)username nick:(NSString *)nickname psword:(NSString *)psword
{
    userName = username;
    nickName = nickname;
    psWord = psword;
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark-
//广播响应函数
-(void)uploadPhotoSuccessful: (NSNotification*)notification
{
    networkPath = notification.object;
    isUploadPhoto = true;
}


-(void)uploadPhotoFailed:(NSNotification *)notification
{
    _errorInfoLabel.text = notification.object;
    _errorInfoLabel.hidden = NO;
}

-(void)registerSuccessful
{
    isRegisterSuccessful = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:@"username"];
    [userDefaults setObject:psWord forKey:@"psword"];
    [userDefaults synchronize];
    
    XTSideMenu *root = [XTSideMenu shareInstance];
    [self.navigationController pushViewController:root animated:YES];
}


-(void)registerFailed:(NSNotification *)notification
{
    _errorInfoLabel.text = notification.object;
    _errorInfoLabel.hidden = NO;
}

#pragma  mark-

-(void)selectIconButtonDown
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
}

-(void)selectGenderButtonDown
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择性别"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"男",@"女",nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

-(void)selectBirthButtonDown
{
    _datePicker = [[UIDatePicker alloc]init];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    NSDateComponents *comp = [[NSDateComponents alloc]init];
    [comp setMonth:01];
    [comp setDay:01];
    [comp setYear:1970];
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *myDate = [myCal dateFromComponents:comp];
    [_datePicker setMinimumDate: myDate];
    [_datePicker setMaximumDate:[NSDate date]];
    [_datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];//地区
    [_datePicker setCalendar:[NSCalendar currentCalendar]];
    [_datePicker setFrame: CGRectMake(0, self.view.frame.size.height - self.view.frame.size.height * 0.35, self.view.frame.size.width, self.view.frame.size.height * 0.3)];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: _datePicker];
}

-(void)datePickerValueChanged
{
    NSDate *birthDate = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [_selectBirthButton setTitle: [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: birthDate]] forState:UIControlStateNormal];
    [_selectBirthButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    
    NSTimeInterval time = [birthDate timeIntervalSince1970] * 1000;//转为时间戳格式
    birthDay = [NSString stringWithFormat:@"%.0lf", time];//转为字符串形式
    isSelectBirth = YES;
}

-(void)completeButtonDown
{
    _errorInfoLabel.hidden = YES;
    if(!isSelectGender)
    {
        _errorInfoLabel.text = @"未选择性别!";
        _errorInfoLabel.hidden = NO;
        return;
    }
    
    if(!isSelectBirth)
    {
        _errorInfoLabel.text = @"未选择生日!";
        _errorInfoLabel.hidden = NO;
        return;
    }
    if(!isSelectPhoto)
    {
        _errorInfoLabel.text = @"未设置头像!";
        _errorInfoLabel.hidden = NO;
        return;
    }
    if(!isUploadPhoto)
    {
        _errorInfoLabel.text = @"正在上传头像……";
        _errorInfoLabel.hidden = NO;
        return;
    }
    
    [[MyServer getServer]registerWithUsername: userName nickname:nickName password:psWord gender:gender birthday:birthDay avatarPath:networkPath];
}



#pragma mark -
#pragma UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0)
    {
        switch (buttonIndex)
        {
            case 0://照相机
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
                break;
            case 1://本地相簿
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }
    else if(actionSheet.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [_selectGenderButton setTitle: @"男" forState:UIControlStateNormal];
                [_selectGenderButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
                gender = @"m";
                isSelectGender = YES;
            }
                break;
            case 1:
            {
                [_selectGenderButton setTitle: @"女" forState:UIControlStateNormal];
                [_selectGenderButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
                gender = @"f";
                isSelectGender = YES;
            }
                break;
        }
    }
}




#pragma mark -
#pragma UIImagePickerController Delegate

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self performSelector:@selector(saveImage:)  withObject:img afterDelay:0.5];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];

    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    UIImage *smallImage = [self thumbnailWithImageWithoutScale: image size: _selectIconButton.frame.size];
    [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];//写入文件
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//读取图片文件
    
    //得到头像的本地路径
    photoPath = imageFilePath;
    [[MyServer getServer] uploadImageByPath: photoPath];
    
    [_profilePhoto setFrame: CGRectMake(0, 0, _selectIconButton.frame.size.width, _selectIconButton.frame.size.height)];
    _profilePhoto.layer.masksToBounds = YES;
    _profilePhoto.layer.cornerRadius = _selectIconButton.frame.size.height / 2;
    _profilePhoto.image = selfPhoto;
    isSelectPhoto = YES;
}

//原比例生成缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image){
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = (asize.width - rect.size.width)/2;
        rect.origin.y = 0;
        /*
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }*/
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

// 改变图像的尺寸，方便上传服务器
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    [_datePicker resignFirstResponder];
    [_datePicker removeFromSuperview];
}

@end
