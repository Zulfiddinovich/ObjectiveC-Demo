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
    NSLog(@"TAG, NotificationService:didReceiveNotificationRequest(), response: @%@", request.identifier);

    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    NSLog(@"TAG, NotificationService:serviceExtensionTimeWillExpire(), ");
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

+ (void)scheduleNotificationWithTitle:  (NSString *)title
                                        body:(NSString *)body
                                        after:(NSTimeInterval)timeInterval
                                        identifier:(NSString *)identifier {
    
    NSLog(@"TAG, NotificationService:scheduleNotificationWithTitle(), ");

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
    NSLog(@"TAG, NotificationService:init(), ");
    self = [super init];
    if (self) {
        // Set up notification categories and actions
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;  // Set the delegate
        
        // Create the actions - matching iOS app identifiers
        UNNotificationAction *yesAction = [UNNotificationAction actionWithIdentifier:@"YES_ACTION"
                                                                            title:@"Yes"
                                                                          options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *noAction = [UNNotificationAction actionWithIdentifier:@"NO_ACTION"
                                                                            title:@"No"
                                                                          options:UNNotificationActionOptionDestructive];
        
        // Create the category with the actions
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"RESPONSE_CATEGORY"
                                                                              actions:@[yesAction, noAction]
                                                                    intentIdentifiers:@[]
                                                                              options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Register the category
        [center setNotificationCategories:[NSSet setWithObject:category]];
        
        // Set up WatchConnectivity
        if ([WCSession isSupported]) {
            NSLog(@"Watch: WatchConnectivity is supported");
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
            NSLog(@"Watch: WatchConnectivity session activated");
            
            // Check if iPhone is reachable
            if (session.isReachable) {
                NSLog(@"Watch: iPhone is reachable");
            } else {
                NSLog(@"Watch: iPhone is not reachable");
            }
        } else {
            NSLog(@"Watch: WatchConnectivity is not supported");
        }
    }
    return self;
}

#pragma mark - WCSessionDelegate Methods

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    if (error) {
        NSLog(@"Watch: WC Session activation failed with error: %@", error.localizedDescription);
        return;
    }
    NSLog(@"Watch: WC Session activated with state: %ld", (long)activationState);
    
    // Check if iPhone is reachable
    if (session.isReachable) {
        NSLog(@"Watch: iPhone is reachable");
    } else {
        NSLog(@"Watch: iPhone is not reachable");
    }
}

- (void)sessionReachabilityDidChange:(WCSession *)session {
    NSLog(@"Watch: iPhone reachability changed: %@", session.isReachable ? @"Reachable" : @"Not Reachable");
}

#if TARGET_OS_IOS
- (void)sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"TAG, NotificationService:sessionDidBecomeInactive(), ");
//    NSLog(@"WC Session did become inactive");
}

- (void)sessionDidDeactivate:(WCSession *)session {
    
    NSLog(@"TAG, NotificationService:sessionDidDeactivate(), ");
    // Reactivate session
    [[WCSession defaultSession] activateSession];
//    NSLog(@"WC Session did deactivate");
}
#endif

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSLog(@"Watch: Received message from iOS: %@", message);
    
    NSString *iosResponse = message[@"iosResponse"];
    if (iosResponse) {
        NSLog(@"Watch: Received iOS response: %@", iosResponse);
        // Handle the iOS response here if needed
    }
    
    if (replyHandler) {
        replyHandler(@{@"watchResponse": @"Received iOS message!"});
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    NSLog(@"Watch: Received application context: %@", applicationContext);
}

#pragma mark - UNUserNotificationCenterDelegate Methods

- (void)userNotificationCenter:(UNUserNotificationCenter *)center 
        willPresentNotification:(UNNotification *)notification 
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"TAG, NotificationService:userNotificationCenter(), with 'willPresentNotification'");
    // Show the notification even when the app is in foreground
    completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center 
        didReceiveNotificationResponse:(UNNotificationResponse *)response 
        withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"TAG, NotificationService:userNotificationCenter(), with 'didReceiveNotificationResponse'");
    
    NSString *actionIdentifier = response.actionIdentifier;
    NSString *notificationIdentifier = response.notification.request.identifier;
    
    if ([actionIdentifier isEqualToString:@"YES_ACTION"]) {
        NSLog(@"User tapped YES for notification: %@", notificationIdentifier);
        // Send message to iOS app
        if ([WCSession defaultSession].isReachable) {
            [[WCSession defaultSession] sendMessage:@{
                @"notificationResponse": @"YES",
                @"notificationIdentifier": notificationIdentifier
            } replyHandler:^(NSDictionary<NSString *,id> *replyMessage) {
                NSLog(@"Message sent to iOS app with reply: %@", replyMessage);
            } errorHandler:^(NSError *error) {
                NSLog(@"Error sending message to iOS app: %@", error);
            }];
        }
    } else if ([actionIdentifier isEqualToString:@"NO_ACTION"]) {
        NSLog(@"User tapped NO for notification: %@", notificationIdentifier);
        // Send message to iOS app
        if ([WCSession defaultSession].isReachable) {
            [[WCSession defaultSession] sendMessage:@{
                @"notificationResponse": @"NO",
                @"notificationIdentifier": notificationIdentifier
            } replyHandler:^(NSDictionary<NSString *,id> *replyMessage) {
                NSLog(@"Message sent to iOS app with reply: %@", replyMessage);
            } errorHandler:^(NSError *error) {
                NSLog(@"Error sending message to iOS app: %@", error);
            }];
        }
    }
    
    completionHandler();
}

@end
