//
//  cosmo_swiftuiApp.swift
//  cosmo-swiftui
//
//  Created by Stuart Wallace on 11/17/22.
//

import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    var screenWidth = NSScreen.main?.frame.width
    var screenHeight = NSScreen.main?.frame.height

    func applicationWillTerminate(_ notification: Notification) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys.filter({ $0.contains("NSWindow Frame") }) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func applicationWillFinishLaunching(_ notification: Notification) {

    }
}


@main
struct cosmo_swiftuiApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    init() {

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("")
        }.defaultSize(width: (appDelegate.screenWidth ?? 0), height: (appDelegate.screenHeight ?? 0))
    }
}

