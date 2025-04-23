//
//  AppDelegate.m
//  ObjectiveC-Demo
//
//  Created by INCHAN KANG on 2018. 4. 4..
//  Copyright © 2018년 INCHAN KANG. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"TAG, AppDelegate:application(), registered and started notification center!");
    // Call for notification category registery
    [self registerNotificationCategories];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self; // Set the delegate
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UNUserNotificationCenterDelegate

// This method is called when the user interacts with a notification action.
- (void)userNotificationCenter: (UNUserNotificationCenter *)center
                                didReceiveResponse:(UNNotificationResponse *)response
                                withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"TAG, AppDelegate:userNotificationCenter(), should be called after user interacts with notification!");
    
    NSString *actionIdentifier = response.actionIdentifier;
    NSString *notificationIdentifier = response.notification.request.identifier; // You might need this

    if ([actionIdentifier isEqualToString:@"YES_ACTION"]) {
        NSLog(@"User tapped 'Yes' on notification: %@", notificationIdentifier);
        // Here you would typically perform the action associated with "Yes"
        // For example, update data, trigger an event, etc.
        [self sendResponseToWatch:@"Yes" forNotification:notificationIdentifier];
    } else if ([actionIdentifier isEqualToString:@"NO_ACTION"]) {
        NSLog(@"User tapped 'No' on notification: %@", notificationIdentifier);
        // Handle the "No" action
        [self sendResponseToWatch:@"No" forNotification:notificationIdentifier];
    }

    // You must call the completion handler when you're done handling the response.
    completionHandler();
}

// This method is called when the app is in the foreground and a notification arrives.
// You can customize how the notification is presented.
- (void)userNotificationCenter: (UNUserNotificationCenter *)center
                                willPresentNotification:(UNNotification *)notification
                                withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"TAG, AppDelegate:userNotificationCenter(), should be called when app is in foreground and notification arrives!");
    
    // Customize presentation options if needed (e.g., show alert, sound, badge even if in foreground)
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

- (void)registerNotificationCategories {
    NSLog(@"TAG, AppDelegate:registerNotificationCategories(), called by AppDelegate:application()!");
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    // Define the "Yes" action
    UNNotificationAction *yesAction = [UNNotificationAction actionWithIdentifier:@"YES_ACTION"
                                                                            title:@"Yes"
                                                                          options:UNNotificationActionOptionForeground]; // Bring app to foreground if tapped

    // Define the "No" action
    UNNotificationAction *noAction = [UNNotificationAction actionWithIdentifier:@"NO_ACTION"
                                                                           title:@"No"
                                                                         options:UNNotificationActionOptionDestructive]; // Indicate a destructive action

    // Create the notification category with the actions
    UNNotificationCategory *responseCategory = [UNNotificationCategory categoryWithIdentifier:@"RESPONSE_CATEGORY"
                                                                                      actions:@[yesAction, noAction]
                                                                            intentIdentifiers:@[]
                                                                                      options:UNNotificationCategoryOptionCustomDismissAction];

    // Register the category with the notification center
    [center setNotificationCategories:[NSSet setWithObject:responseCategory]];
}

- (void)sendResponseToWatch:(NSString *)response
                            forNotification:(NSString *)identifier {
    NSLog(@"TAG, AppDelegate:sendResponseToWatch(), response: @%@", response);
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        if (session.isPaired && session.isWatchAppInstalled) {
            NSDictionary *payload = @{@"notificationResponse": response, @"notificationIdentifier": identifier};
            [session sendMessage:payload
                   replyHandler:nil // Optional: Handle a reply from the watch app
                  errorHandler:^(NSError *error) {
                      NSLog(@"Error sending message to watch: %@", error);
                  }];
        } else {
            NSLog(@"Watch session is not active or watch app is not installed.");
        }
    } else {
        NSLog(@"Watch Connectivity is not supported on this device.");
    }
}

@end
