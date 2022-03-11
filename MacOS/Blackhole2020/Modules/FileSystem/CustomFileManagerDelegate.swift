//
//  CustomFileManagerDelegate.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 3/28/21.
//

import Foundation

class CustomFileManagerDelegate: NSObject, FileManagerDelegate {
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
        // Don't delete PDF files
        // return URL.pathExtension != "pdf"

        // allow deletion of everything for now
        print("fileManager -- shouldRemoveItemAt url=\(URL)")
        return true
    }
}
