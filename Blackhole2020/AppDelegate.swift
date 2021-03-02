//
//  AppDelegate.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import Cocoa
import SwiftUI
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
//import SDWebImageLottieCoder // for the coder, if we want to bring it back

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = BlackHoleView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        // Add coder for rlottie support
        //let lottieCoder = SDImageLottieCoder.shared
        //SDImageCodersManager.shared.addCoder(lottieCoder)
        
        AppCenter.start(withAppSecret: "c9e9af8c-92d6-4654-9452-313c96f20102", services:[
          Analytics.self,
          Crashes.self
        ])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        print("opening files...")
    }

}

