//
//  NotificationService.h
//  ObjectiveC-Demo
//
//  Created by Zukhriddin Kamolov on 22/04/25.
//  Copyright © 2025 INCHAN KANG. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

@interface NotificationService : UNNotificationServiceExtension

+ (void)scheduleNotificationWithTitle:  (NSString *)title
                                        body:(NSString *)body
                                        after:(NSTimeInterval)timeInterval
                                        identifier:(NSString *)identifier;

@end
