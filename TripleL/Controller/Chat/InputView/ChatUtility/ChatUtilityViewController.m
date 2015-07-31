//
//  DDDDChatUtilityViewController.m
//  Emoji
//
//  Created by YiLiFILM on 14/12/13.
//  Copyright (c) 2014年 YiLiFILM. All rights reserved.
//
//static NSString * const ItemCellIdentifier = @"ItemCellIdentifier";
#import "ChatUtilityViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UtililyItemCell.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ChatUtilityItem.h"
#import "AppDelegate.h"
#import "MyHeader.h"

#define KOriginalPhotoImagePath  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ChatImages"]

#define KVideoUrlPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ChatVideos"]

@interface ChatUtilityViewController ()
@property(nonatomic,strong)NSArray *itemsArray;
@end

@implementation ChatUtilityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ChatUtilityItem *item1 = [ChatUtilityItem new];
    item1.itemName=@"拍摄";
    item1.itemLogo=@"dd_take-photo";
    ChatUtilityItem *item2 = [ChatUtilityItem new];
    item2.itemName=@"照片";
    item2.itemLogo=@"dd_album";
    ChatUtilityItem *item3 = [ChatUtilityItem new];
    item3.itemName=@"视频";
    item3.itemLogo=@"dd_video";
    ChatUtilityItem *item4 = [ChatUtilityItem new];
    item4.itemName=@"文件";
    ChatUtilityItem *item5 = [ChatUtilityItem new];
    item5.itemName=@"位置";
    self.itemsArray =@[item1,item2,item3];
    
    self.gridView =[[AQGridView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    [self.view addSubview:self.gridView];
    
    self.gridView.delegate = self;
	self.gridView.dataSource = self;
    [self.gridView reloadData];
    self.view.backgroundColor=[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
}

- (void) viewDidUnload
{
    self.gridView = nil;
}


#pragma mark AQGridViewControll Delegate
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return  [self.itemsArray count];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    
    UtililyItemCell * cell = (UtililyItemCell *)[self.gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
    if ( cell == nil ){
        cell = [[UtililyItemCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 55.0, 55.0) reuseIdentifier: PlainCellIdentifier] ;
        // cell.selectionGlowColor = [UIColor purpleColor];
    }
    ChatUtilityItem *item =[self.itemsArray objectAtIndex: index];
    cell.icon.image = [UIImage imageNamed: item.itemLogo];
    cell.title.text=item.itemName;
    return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    [gridView deselectItemAtIndex:index animated:YES];
    UtililyItemCell * cell = (UtililyItemCell *)[self.gridView cellForItemAtIndex: index];
    if ([cell.title.text isEqualToString:@"拍摄"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            self.imagePicker.mediaTypes = @[@"public.image", @"public.movie"];
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            UIViewController * detail = (UIViewController *)self.delegate;
            [detail.navigationController presentViewController:self.imagePicker animated:NO completion:nil];
        });
        
    }
    else if ([cell.title.text isEqualToString:@"照片"]){
        self.imagePicker.mediaTypes = @[@"public.image"];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    else if ([cell.title.text isEqualToString:@"视频"]){
        self.imagePicker.mediaTypes = @[@"public.movie"];
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
      self.imagePicker=nil;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        
        __block UIImage *theImage = nil;
        if ([picker allowsEditing]){
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        UIImage *image = [self scaleImage:theImage toScale:1];
        NSData *imageData = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        NSString *filePath = [NSString stringWithFormat:@"%@%@%ld.png", FILE_DOC, FILE_IMAGE, (long)([[NSDate date] timeIntervalSince1970] * 10000)];
        [imageData writeToFile:filePath atomically:YES];

        [self.delegate pickerImage:filePath];
        [picker dismissViewControllerAnimated:NO completion:nil];
        self.imagePicker = nil;
    }
    else if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *fileName = [NSString stringWithFormat:@"%ld%@", (long)([[NSDate date] timeIntervalSince1970] * 10000),videoURL.lastPathComponent];
        NSString * videoPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_VIDEO, fileName];
        
        AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:AVAssetExportPresetHighestQuality];
        //AVAssetExportPresetHighestQuality 压缩率很低
        //其他值可以查看，根据自己的需求确定
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];//输出的上传路径，文件不能已存在
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCompleted");
                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
                    gen.appliesPreferredTrackTransform = YES;
                    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                    NSError *error = nil;
                    CMTime actualTime;
                    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                    CGImageRelease(image);
                    
                    NSString * imagePath = [NSString stringWithFormat:@"%@%@.png",KOriginalPhotoImagePath,fileName];
                    NSData *data = UIImageJPEGRepresentation(thumb, 0);
                    [data writeToFile:imagePath atomically:YES];
                    
                    [self.delegate pickerMovie:videoPath thumbPath:imagePath];
                    [picker dismissViewControllerAnimated:NO completion:nil];
                    self.imagePicker=nil;
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusFailed");
                    NSLog(@"error:%@",exportSession.error);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCancelled");
                    break;
                default:
                    break;
            }
        }];
    }
}
#pragma mark -
#pragma mark 等比縮放image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
