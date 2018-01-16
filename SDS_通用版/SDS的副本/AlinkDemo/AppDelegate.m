//
//  AppDelegate.m
//  AlinkDemo
//
//  Created by Dong on 2016/12/28.
//  Copyright © 2016年 aliyun. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

#import <AlinkSDK/AlinkOpenSDK.h>
#import <BoneKit/BoneKit.h>
#import <BoneKit/BoneRCTUtils.h>

#import <NetworkCore/NWNetworkConfiguration.h>
#import <TBAccsSDK/TBAccsManager.h>
#import <PushCenterSDK/TBSDKPushCenterEngine.h>

#import <ALBBOpenAccountSDK/ALBBOpenAccountSDK.h>
#import <AKDebugDashboard/AKDebugDashboard.h>

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DemoLoggingFormatter.h"

#import "WebURLHandler.h"
#import "CustomLoginMoudle.h"
#import "ViewController.h"

 

#import "MyLoginMoudle.h"
DDLogLevel ddLogLevel = DDLogLevelAll;

@interface AppDelegate () <UISplitViewControllerDelegate,UNUserNotificationCenterDelegate,BLControllerDelegate>
@property(nonatomic,strong)TBAccsManager*accsManager;
@property(nonatomic,strong)NSData*deviceToken;
@property(nonatomic,strong)BLLet *let;
@property(nonatomic,strong) UISegmentedControl *Boneseg,*seg;
@end

@implementation AppDelegate
{
    // iOS 10通知中心
    UNUserNotificationCenter *_notificationCenter;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置AKDebug工具面板，接入DDLog到日志模块
//    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
//    ttyLogger.logFormatter = [DemoLoggingFormatter new];
//    [DDLog addLogger:ttyLogger];
//    [AKDebugDashboard sharedDashboard].fullScreen = NO;
    /*SDS项目 开发代码内容  基础框架 如下/上*/
    MainViewController *mainVC = [[MainViewController    alloc]init];
     UIStoryboard * strory = [UIStoryboard  storyboardWithName:@"LeftMenuViewController" bundle:[NSBundle mainBundle]];
    LeftMenuViewController *leftVC = [strory instantiateViewControllerWithIdentifier:@"LeftMenu"];
    UINavigationController *centerNvaVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
    UINavigationController *leftNvaVC = [[UINavigationController alloc]initWithRootViewController:leftVC];
    //3、使用MMDrawerController
    self.drawerController = [[MMDrawerController alloc]initWithCenterViewController:centerNvaVC leftDrawerViewController:leftNvaVC];
    //4、设置打开/关闭抽屉的手势
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
    //5、设置显示的多少
    self.drawerController.maximumLeftDrawerWidth = SCREEN_WIDTH/4*3;
    
    //6、初始化窗口、设置根控制器、显示窗口
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    self.window.rootViewController = nav;
    nav.navigationBarHidden = YES;
    
     //[self.window setRootViewController: nav];
      [self.window setRootViewController: self.drawerController];
    [self.window makeKeyAndVisible];
     /*SDS项目 开发代码内容  基础框架 如下/上*/
    
    
#warning  请先配置好 Bundle ID 和 安全图片(yw_1222.jpg)!!!
    [self setupAPNS:application];
    
    //设置AlinkSDK环境，指定appKey
    AlinkEnvConfig *envConfig = [AlinkEnvConfig sharedInstance];
    envConfig.appKey = @"24544065";
    
//    //打开日志模块，Release版本请记得关闭
   [envConfig openDebugLog:YES];
    
    //安装自定义登录协议，默认实现是OpenAccount，自定义登录协议请参照实现

    MyLoginMoudle *module = [[MyLoginMoudle alloc]init];
    [[AlinkAccount sharedInstance] installCustomLoginModule:module];
    
    //初始化AlinkSDK
    [kAlinkSDK asyncInit:^(NSError * _Nullable error) {
        if (!error) {
            DDLogInfo(@"AlinkSDK 初始化成功");
            //初始化完成，设置应用内下行通知回调（如：设备状态变更），也可通过监听kAKNotificationDownStream通知
            [kAlinkSDK setDownStreamCallback:^(NSDictionary * _Nonnull dict) {
                NSString *str = [NSString stringWithFormat:@"收到downStream: %@", dict];
                DDLogInfo(@"%@", str);
            }];
            return;
        }
        
        DDLogError(@"AlinkSDK 初始化错误：%@", error);
    }];
    
    //设置Bone环境
    if ([self currentBoneENV] == 0) {
        BoneRCTSetCDNEnvironment(@"alpha");
    }else if ([self currentBoneENV] == 1){
        BoneRCTSetCDNEnvironment(@"test");
    }else{
        BoneRCTSetCDNEnvironment(@"release");
    }
    
    /*
     BoneRouter 又称为统一路由，是为整个 APP 提供路由导航功能，包括但不限于：
     
     从一个 APP 跳转到另一个 APP
     从一个 Native 页面跳转到另一个 Native 页面
     从一个 Native 页面跳转到另一个 Bone React Native 容器
     从一个 Bone React Native 容器跳转到另一个 Naitve 页面
     从一个 Bone React Native 容器跳转到另一个 Bone React Native 容器
     
     参考文档：https://open.aliplus.com/bone/core/router.html
     */
//    //注册自定义路由模块，这里注册一个WebView路由跳转Handler
//    [[BoneRouter defaultRouter] registerSubRouter:[WebURLHandler class]];
//
//
//    [self initSwitherWithFrame:self.window.bounds];
    [self loadAppSdk];
    return YES;
}


- (void)loadAppSdk {
    self.let = [BLLet sharedLetWithLicense:@"eXvqmOCozfEpGyAJBkl5hGmW/LCXNB7ea45CqFlfboVS3p1K6KHzSVl54tgpbw5nrHPoWQAAAACIWIhYgyIAzT36dGvsKN4bzAReGkwnmhezW5Y05374efmibKIXBssLcNEQNdjg0wvSd7CeFaOhhB3TR3ltupsAsEkbxXTfoUSQjDzWcfVjcAAAAAA="];        // Init APPSDK
    self.let.debugLog = BL_LEVEL_NONE;                           // Set APPSDK debug log level
    
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_ALL];     // Set DNASDK debug log level
    [self.let.controller startProbe];                           // Start probe device
    self.let.controller.delegate = self;
    
    self.let.configParam.controllerSendCount = 2;
//    self.let.configParam.controllerRepeatCount = 3;
    
   // BLPicker *pick = [BLPicker sharedPickerWithConfigParam:self.let.configParam];
   // [pick startPick];
    
 
}

- (void)setupAPNS:(UIApplication *)application {
    [NWNetworkConfiguration setAcsCenterHosts:@"openacs.m.taobao.com" debugHost:@"openacs.m.taobao.com" dailyHost:@"openacs.m.taobao.com"];
    [NWNetworkConfiguration setAmdcHosts:@"openjmacs.m.taobao.com" debugHost:@"openjmacs.m.taobao.com" dailyHost:@"openjmacs.m.taobao.com"];
    
    
    [NWNetworkConfiguration setAcsCenterIPs:@[@"140.205.160.76"] debugIps:@[@"140.205.172.12"] dailyIps:@[@"140.205.160.76"]];
    [NWNetworkConfiguration setAmdcIPs:@[@"140.205.163.94"] debugIps:@[@"110.75.206.79"] dailyIps:@[@"140.205.163.94"]];
    
    [NWNetworkConfiguration shareInstance].clusterPublickey = @"OPEN";
    [NWNetworkConfiguration setEnvironment:release];
    [TBAccsManager setCenterHost:@"openacs.m.taobao.com"];
    _accsManager = [TBAccsManager centerAccsManager];
    [_accsManager startAccs];
    
    [self bindAppleToken];
    
    [self registerAPNS:application];
}


-(void)initSwitherWithFrame:(CGRect)frame{
    
    UIView*envView=[[UIView alloc] initWithFrame:frame];
    
    UILabel*BoneENV=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, envView.frame.size.width/3, 30)];
    [envView addSubview:BoneENV];
    BoneENV.text=@"Bone环境";
    
    self.Boneseg=[[UISegmentedControl alloc] initWithFrame:CGRectMake(10, 80, envView.frame.size.width/2, 30)];
    [self.Boneseg insertSegmentWithTitle:@"内测" atIndex:0 animated:NO];
    [self.Boneseg insertSegmentWithTitle:@"厂测" atIndex:1 animated:NO];
    [self.Boneseg insertSegmentWithTitle:@"线上" atIndex:2 animated:NO];
    
    [envView addSubview:self.Boneseg];
    [self.Boneseg setSelectedSegmentIndex:[self currentBoneENV]];
    
    
    [[AKDebugDashboard sharedDashboard] insertSegmentWithTitle:@"环境切换" view:envView atIndex:1];
    
    
    UIButton*confirm= [UIButton buttonWithType:UIButtonTypeSystem];
    confirm.frame=CGRectMake((frame.size.width-100)/2, frame.size.height-200, 100, 40);
    [envView addSubview:confirm];
    [confirm setTitle:@"确定" forState:UIControlStateNormal ];
    [confirm.layer setMasksToBounds:YES];
    [confirm.layer setCornerRadius:5.0];
    [confirm.layer setBorderWidth:1];
    confirm.layer.borderColor=confirm.titleLabel.textColor.CGColor;
    
    
    [confirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    
    [self currentBoneENV];
    
}




-(NSInteger)currentBoneENV{
    NSNumber*BoneENV=[[NSUserDefaults standardUserDefaults] objectForKey:@"BoneENV"];
    return BoneENV?[BoneENV integerValue]:2;
}


-(void)confirm{
    DDLogInfo(@"%ld",self.seg.selectedSegmentIndex);
    [[NSUserDefaults standardUserDefaults] setInteger:self.Boneseg.selectedSegmentIndex forKey:@"BoneENV"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AlinkAccount sharedInstance] logout:^(NSError * _Nonnull error) {
        
    }];
    [self performSelector:@selector(reboot) withObject:nil afterDelay:1];
}

-(void)reboot{
     exit(0);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.deviceToken=deviceToken;
    //上传deviceToken
    TBSDKPushCenterEngine *pushCenterEngine = [TBSDKPushCenterEngine shareInstance];
    [pushCenterEngine upLoaderDeviceToken: self.deviceToken
                                 userInfo: nil
                       uploadSuccessBlock: ^(TBSDKPushCenterModel *model)
     {
         DDLogInfo(@"成功:上传deviceToken");
     }
                          uploadFailBlock: ^(TBSDKPushCenterModel *model, TBSDKPushErrorResponse *error)
     {
         DDLogInfo(@"失败:上传deviceToken, error = %@", [error description]);
     }];
}


-(void)bindAppleToken{
    [_accsManager bindAppWithAppleToken: nil
                               callBack:^(NSError *error, NSDictionary *resultsDict) {
                                   if (error) {
                                       DDLogInfo(@"绑定App出错了 %@", error);
                                       
                                   }
                                   else {
                                       DDLogInfo(@"绑定App成功了");
                                   }
                               }];
}




- (void)registerAPNS:(UIApplication *)application {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [ALBBService(ALBBOpenAccountSSOService) handleOpenUrl:url];
    if (!result) {
        //用户其他操作
        return NO;
    }
    return result;
    
}


/*
 id<IOpenStaticDataStoreComponent> component = [[OpenSecurityGuardManager getInstance] getStaticDataStoreComp];
 NSInteger keyType = [component getKeyType: @"myKey" authCode: @"myAuthCode"];
 NSLog(@"my key type is:%@",[NSString stringWithFormat: @"%d", keyType]);
 
 
 NSString* extraData = [component getExtraData: @"myKey" authCode: @"myAuthCode"];
 if(extraData)
 NSLog(@"my extradata:%@", extraData);
 
 NSString* appKey0 = [component getAppKey: [NSNumber numberWithInt: 0] authCode: @"myAuthCode];
 if(appKey0)
 NSLog(@"my appKey 0:%@", appKey0);
 */




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"applicationWillEnterForeground" object:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CHONGFUSHEZHI"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ZHIXINGCAOZUO"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ZHIXINGSHIJING"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CLOSEZHIXINGSHIJING"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
