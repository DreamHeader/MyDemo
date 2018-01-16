//
//  AppDelegate.h
//  AlinkDemo
//
//  Created by Dong on 2016/12/28.
//  Copyright © 2016年 aliyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "MainViewController.h"
#import "LeftMenuViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) MMDrawerController * drawerController;
@end

