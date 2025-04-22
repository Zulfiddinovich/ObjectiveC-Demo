//
//  WatchDemoApp.swift
//  WatchDemo Watch App
//
//  Created by Zukhriddin Kamolov on 18/04/25.
//  Copyright © 2025 INCHAN KANG. All rights reserved.
//

import SwiftUI

@main
struct WatchDemo_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: {
                #if os(watchOS)
                NSLog("Should trigger notifiction!")
                trigger()
                #endif
            })
        }
    }

    func trigger(){
        // Objective-C notification controller
        NotHelper().fireNotification()
    }
}
