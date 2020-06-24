//
//  DateFormatter+Extensions.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/27/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let dayOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
