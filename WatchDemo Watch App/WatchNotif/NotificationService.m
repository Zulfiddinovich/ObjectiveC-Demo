//
//  NotificationService.m
//  WatchNotif
//
//  Created by Zukhriddin Kamolov on 18/04/25.
//  Copyright © 2025 INCHAN KANG. All rights reserved.
//

#import "NotificationService.h"
//#import "YourAppName_WatchKit_Extension-Swift.h" // If you have Swift files in your Watch Extension
#import <WatchConnectivity/WatchConnectivity.h>

@interface NotificationService () <WCSessionDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:  (UNNotificationRequest *)request
                                        withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

+ (void)scheduleNotificationWithTitle:  (NSString *)title
                                        body:(NSString *)body
                                        after:(NSTimeInterval)timeInterval
                                        identifier:(NSString *)identifier {

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    // permission handler
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Notification permissions not granted!");
                              } else {
                                  NSLog(@"Notification permissions granted!");
                              }
                          }];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];

    // Set the category identifier here
    content.categoryIdentifier = @"RESPONSE_CATEGORY";

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                        content:content
                                                                        trigger:trigger];

    NSLog(@"Should trigger notification! 3");

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error scheduling notification: %@", error);
        }
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([WCSession isSupported]) {
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        } else {
            NSLog(@"Watch Connectivity is not supported on this device.");
        }
    }
    return self;
}

#pragma mark - WCSessionDelegate Methods

- (void)session: (WCSession *)session
                 activationDidCompleteWithState:(WCSessionActivationState)activationState
                 error:(NSError *)error {
    if (error) {
        NSLog(@"WC Session activation failed with error: %@", error.localizedDescription);
        return;
    }
    NSLog(@"WC Session activated with state: %ld", (long)activationState);
}

#if TARGET_OS_IOS
- (void)sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"WC Session did become inactive");
}

- (void)sessionDidDeactivate:(WCSession *)session {
    // Reactivate session
    [[WCSession defaultSession] activateSession];
    NSLog(@"WC Session did deactivate");
}
#endif

- (void)session: (WCSession *)session
                 didReceiveMessage:(NSDictionary<NSString *, id> *)message
                 replyHandler:(void (^)(NSDictionary<NSString *, id> * _Nonnull))replyHandler {
    
    NSString *response = message[@"notificationResponse"];
    NSString *identifier = message[@"notificationIdentifier"];

    if (response && identifier) {
        NSLog(@"Received response '%@' for notification: %@ on the watch.", response, identifier);
        // Handle the received response on your watch app
        // For example, update your watch app's UI or data based on the user's choice.

        // Optionally send a reply back to the iOS app
        if (replyHandler) {
            replyHandler(@{@"watchResponse": @"Received!"});
        }
    }
}

@end
