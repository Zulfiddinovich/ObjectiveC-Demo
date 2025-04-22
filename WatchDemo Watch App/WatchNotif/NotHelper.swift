//
//  NotHelper.swift
//  ObjectiveC-Demo
//
//  Created by Zukhriddin Kamolov on 22/04/25.
//  Copyright © 2025 INCHAN KANG. All rights reserved.
//

import Foundation

public class NotHelper {
    
    func fireNotification(){
        NSLog("Should trigger notifiction! 2")
        let notificationTitle = "Hello from Swift!"
        let notificationBody = "This notification was scheduled from Swift code using an Objective-C controller."
        let delayInSeconds: TimeInterval = 5
        let notificationIdentifier = "mySwiftTriggeredNotification"
    
        NotificationService.scheduleNotification(withTitle: notificationTitle,
                                                            body: notificationBody,
                                                            after: delayInSeconds,
                                                            identifier: notificationIdentifier)
    }
}
