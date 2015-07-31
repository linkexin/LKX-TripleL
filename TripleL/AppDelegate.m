//
//  AppDelegate.m
//  TripleL
//
//  Created by 李伯坤 on 15/4/13.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "MyHeader.h"
#import "XTSideMenu.h"
#import "MenuViewController.h"
#import "LTHPasscodeViewController.h"
#import "SCLAlertView.h"
#import "ChatViewController.h"

#import "GuideViewController.h"

@interface AppDelegate () <LTHPasscodeViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"APP Path: %@", FILE_DOC);
    
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    if (sysVersion >= 8.0) {
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    [self initSettings];
    
    [self makedirIfNeed];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationController = [[UINavigationController alloc] init];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_bar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setFrame: CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height )];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    RootViewController *rootVC = [RootViewController getRootViewController];
    self.window.rootViewController = rootVC;
    [self.navigationController pushViewController:self.window.rootViewController animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    
    [self removeLocalNotication];
    
//    GuideViewController *guideViewController = [[GuideViewController alloc] init];
//    self.window.rootViewController=guideViewController;
//    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

    [LTHPasscodeViewController setUsername:username andServiceName:@"iOS"];
    if (username != nil && [LTHPasscodeViewController passcodeExistsInKeychain]) {
        [LTHPasscodeViewController sharedUser].delegate = self;
        [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation: YES];
    }
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void) application: (UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // 本地推送
//    NSDictionary *dic = notification.userInfo;
//    NSString *username = [dic objectForKey:@"username"];
//    TLUser *user = [[DataCenter getDataCenter] getFriendListItem:username fromUser:[[MyServer getServer] getSelfAccountInfo].username];
//    [ChatViewController getChatViewController].selfUser = [[MyServer getServer] getSelfAccountInfo];
//    [ChatViewController getChatViewController].friendUser = user;
//    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SHOWCHATVC object:nil];
}

- (void) removeLocalNotication {
    // 获得 UIApplication
    
    UIApplication *app = [UIApplication sharedApplication];
    
    //获取本地推送数组
    
    NSArray *localArray = [app scheduledLocalNotifications];
    
    //声明本地通知对象
    
    UILocalNotification *localNotification;
    
    if (localArray) {
        
        
        for (UILocalNotification *noti in localArray) {
            
            
            NSDictionary *dict = noti.userInfo;
            
            
            if (dict) {
                
                
                NSString *inKey = [dict objectForKey:@"key"];
                
                
                if ([inKey isEqualToString:@"对应的key值"]) {
                    
                    
                    if (localNotification){
                        
                        
                        
                        
                        localNotification = nil;
                        
                        
                    }
                    
                    
                    
                    
                    break;
                    
                    
                }
                
                
            }
            
            
        }
        
        
        //判断是否找到已经存在的相同key的推送
        
        
        if (!localNotification) {
            
            
            //不存在初始化
            
            
            localNotification = [[UILocalNotification alloc] init];
            
            
        }
        
        
        
        
        if (localNotification) {
            
            
            //不推送 取消推送
            
            
            [app cancelLocalNotification:localNotification];
            

            
            
            return;
            
            
        }
        
    }
}

- (void) initSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"fontStyle"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"colorStyle"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"puppleStyle"];
    }
}

- (void) makedirIfNeed
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL ok;
    NSError *error;
    NSString *path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_IMAGE];
    if (![fileManager isExecutableFileAtPath:path]) {
        ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ok) {
            NSLog(@"create file error: %@", error);
        }
    }
    
    path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_VOICE];
    if (![fileManager isExecutableFileAtPath:path]) {
        ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ok) {
            NSLog(@"create file error: %@", error);
        }
    }

    path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_VIDEO];
    if (![fileManager isExecutableFileAtPath:path]) {
        ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ok) {
            NSLog(@"create file error: %@", error);
        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coredata" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coredata.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - lth

- (void)maxNumberOfFailedAttemptsReached
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];

    [[LTHPasscodeViewController sharedUser]dismissMe];
    [alert addButton:@"确定" actionBlock:^{
        [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] andServiceName:@"iOS" error:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"psword"];
        [[MyServer getServer] logout];
        [[RootViewController getRootViewController] logout];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
    [alert showError:[XTSideMenu shareInstance] title:@"警告" subTitle:@"由于您输错密码次数过多，现在将注销此账号，并清空其短密码！" closeButtonTitle:nil duration:0];
}

- (void)passcodeWasEnteredSuccessfully
{
    MyServer *server = [MyServer getServer];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"psword"];
    NSLog(@"username = %@， password = %@", username, password);
    [server loginWithUsername:username andPassword:password];
}




@end
