//
//  ModifyAvatarViewController.m
//  TripleL
//
//  Created by charles on 5/18/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyAvatarViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

#define LENGTH 150
#define INDEX 0

@interface ModifyAvatarViewController ()
{
    NSString *photoPath;
}

@property (strong, nonatomic)UILabel *tipLabel;
@property (strong, nonatomic)UIView *bgView;
@property (strong, nonatomic)UIButton *selectIconButton;
@property (strong, nonatomic)UIImageView *profilePhoto;
@end

@implementation ModifyAvatarViewController

-(void)viewDidLoad
{
    self.view.backgroundColor = [AppConfig getBGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    _selectIconButton = [[UIButton alloc]init];
    [_selectIconButton.layer setCornerRadius: 5];
    _selectIconButton.backgroundColor = [UIColor colorWithRed:211 green:211 blue:211 alpha:1];
    [_selectIconButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectIconButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _selectIconButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _selectIconButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 10);
    _profilePhoto= [[UIImageView alloc]init];//WithImage:[UIImage imageNamed:@"selectIcon.png"]];
    [_profilePhoto sd_setImageWithURL:[NSURL URLWithString:[DetailInfoCenter getDetailInfoCenter].selfInfo.avatar]placeholderImage:[UIImage imageNamed:[DetailInfoCenter getDetailInfoCenter].avater]];
    //NSLog(@"%@", [DetailInfoCenter getDetailInfoCenter].avater);
    _profilePhoto.layer.masksToBounds = YES;
    [_profilePhoto.layer setCornerRadius: 5];
    [_selectIconButton addSubview:_profilePhoto];
    [_selectIconButton addTarget:self action:@selector(selectIconButtonDown) forControlEvents:UIControlEventTouchUpInside];
    _selectIconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _selectIconButton.userInteractionEnabled = YES;
    
    
    _tipLabel = [[UILabel alloc]init];
    //_tipLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX]objectForKey:@"tip"];
    _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:_tipLabel];
    [self.view addSubview:_selectIconButton];
    
    [self orientChange:nil];
}

-(void)selectIconButtonDown
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机", @"本地相簿",nil];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
}

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
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"selfPhoto%d.png", [DetailInfoCenter getDetailInfoCenter].photoIndex]];
    
    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    UIImage *smallImage = [self thumbnailWithImageWithoutScale: image size: _selectIconButton.frame.size];
    [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];//写入文件
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//读取图片文件
    
    //得到头像的本地路径
    photoPath = imageFilePath;
    //NSLog(@"photopath = %@", photoPath);
    
    [_profilePhoto setFrame: CGRectMake(0, 0, _selectIconButton.frame.size.width, _selectIconButton.frame.size.height)];
    _profilePhoto.layer.masksToBounds = YES;
    _profilePhoto.layer.cornerRadius = 5;
    _profilePhoto.image = selfPhoto;
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


- (void)orientChange:(NSNotification *)noti
{
    _selectIconButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - LENGTH / 2, [UIScreen mainScreen].bounds.size.height * 0.2, LENGTH, LENGTH);
    [_profilePhoto setFrame: CGRectMake(0, 0,LENGTH, LENGTH)];
    _tipLabel.frame = CGRectMake(20, _selectIconButton.frame.origin.y +_selectIconButton.frame.size.height + 50,[UIScreen mainScreen].bounds.size.width / 2, 30);
    _tipLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2 - LENGTH / 2, _selectIconButton.frame.origin.y + _selectIconButton.frame.size.height + 50);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    photoPath = nil;
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (uploadPhotoSuccessful:) name:INFO_UPLOADIMAGESUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPhotoFailed:) name:INFO_UPLOADIMAGEFAILDE object: nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(photoPath != nil)
    {
        [[MyServer getServer] uploadImageByPath: photoPath];
        [DetailInfoCenter getDetailInfoCenter].avater = photoPath;
        [DetailInfoCenter getDetailInfoCenter].selfInfo.avatar = photoPath;
        [DetailInfoCenter getDetailInfoCenter].photoIndex ++;
    }
}

#pragma  mark-
//广播响应函数
-(void)uploadPhotoSuccessful: (NSNotification*)notification
{
    //NSLog(@"success");
    [DetailInfoCenter getDetailInfoCenter].avater = notification.object;
    [DetailInfoCenter getDetailInfoCenter].selfInfo.avatar = notification.object;
}


-(void)uploadPhotoFailed:(NSNotification *)notification
{
    
}

@end
