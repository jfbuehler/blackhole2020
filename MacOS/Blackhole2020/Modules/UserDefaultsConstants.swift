//
//  UserDefaultsConstants.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 3/31/21.
//

import Foundation

class UserDefaultsConstants {
    static let run_count = "run_count"
    static let files_destroyed = "files_destroyed"
    static let megabytes_destroyed = "megabytes_destroyed"
}

extension UserDefaults {
    static func increment(val: Int, key: String) {
        var old_val = UserDefaults.standard.integer(forKey: key)
        old_val += val
        UserDefaults.standard.set(old_val, forKey: key)
    }
}
