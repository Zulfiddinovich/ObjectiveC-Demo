//
//  AppDelegate.h
//  ObjectiveC-Demo
//
//  Created by INCHAN KANG on 2018. 4. 4..
//  Copyright © 2018년 INCHAN KANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h> // Make sure this is imported

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

