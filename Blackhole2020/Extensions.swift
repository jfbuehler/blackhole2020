//
//  Extensions.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 1/23/21.
//

import SwiftUI

extension NSOpenPanel {
    
    static func openImage(completion: @escaping (_ result: Result<NSImage, Error>) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["jpg", "jpeg", "png", "heic"]
        panel.canChooseFiles = true
        panel.begin { (result) in
            if result == .OK,
                let url = panel.urls.first,
                let image = NSImage(contentsOf: url) {
                completion(.success(image))
            } else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension NSApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
