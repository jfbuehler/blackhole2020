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
import Lottie
// import SDWebImageLottieCoder // for the coder, if we want to bring it back

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var helpWindow: NSWindow!
    var statsWindow: NSWindow!

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

        // UserDefaults.standard.set(false, forKey: "didLaunchBefore")
        if !UserDefaults.standard.bool(forKey: "didLaunchBefore") {
            UserDefaults.standard.set(true, forKey: "didLaunchBefore")

            print("didLaunchBefore = false")
            let helpView = HelpView()
            helpWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            helpWindow.center()
            helpWindow.contentView = NSHostingView(rootView: helpView)
            helpWindow.makeKeyAndOrderFront(nil)
        } else {
            print("didLaunchBefore = true")
        }

        // Enable to start with music
        // JonsMusicPlayer.sharedInstance.toggle_on_off()

        // This is one way we can track stats on MacOS -- it uses Microsoft's App Center analytics, which runs on Windows projects as well.
        // Firebase is tough because Windows has almost zero support for it.
//        AppCenter.start(withAppSecret: "xxxXXXxxx", services: [
//          Analytics.self,
//          Crashes.self
//        ])

        var runs = UserDefaults.standard.integer(forKey: UserDefaultsConstants.run_count)
        runs += 1
        UserDefaults.standard.set(runs, forKey: UserDefaultsConstants.run_count)
        print("runs = \(runs)")

        Analytics.trackEvent("Run Count", withProperties: ["count": "\(runs)"])

        // Use the Core Animation rendering engine if possible,
        // otherwise fall back to using the Main Thread rendering engine.
        //  - Call this early in your app lifecycle, such as in the AppDelegate.
        LottieConfiguration.shared.renderingEngine = .automatic
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

    @IBAction func music_toggle(_ sender: Any) {
        print("music toggle")
        JonsMusicPlayer.sharedInstance.toggle_on_off()
    }

    @IBAction func pause_toggle(_ sender: Any) {

        // notify file erasing to STOP -- maybe we support pausing in the future...
        NotificationCenter.default.post(name: .init("pause_toggle"), object: nil)
    }

    @IBAction func help_toggle(_ sender: Any) {

        let helpView = HelpView()
        helpWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        helpWindow.center()
        helpWindow.isReleasedWhenClosed = false
        helpWindow.contentView = NSHostingView(rootView: helpView)
        helpWindow.makeKeyAndOrderFront(nil)
    }

    @IBAction func stats_toggle(_ sender: Any) {

        var statsView = StatsView()

        // load data
        statsView.files_destroyed = UserDefaults.standard.integer(forKey: UserDefaultsConstants.files_destroyed)
        statsView.megabytes_destroyed = UserDefaults.standard.integer(forKey: UserDefaultsConstants.megabytes_destroyed)
        statsView.visits = UserDefaults.standard.integer(forKey: UserDefaultsConstants.run_count)

        statsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        statsWindow.center()
        statsWindow.isReleasedWhenClosed = false
        statsWindow.contentView = NSHostingView(rootView: statsView)
        statsWindow.makeKeyAndOrderFront(nil)
    }

    @IBAction func options_toggle(_ sender: Any) {

    }

}
