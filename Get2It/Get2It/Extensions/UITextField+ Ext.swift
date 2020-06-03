//
//  UITextField+ Ext.swift
//  Get2It
//
//  Created by Vici Shaweddy on 5/22/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

extension UITextField {
    func toTrimmedString() -> String? {
        let ws = CharacterSet.whitespacesAndNewlines
        guard let trimmed = text?.trimmingCharacters(in: ws), !trimmed.isEmpty else {
            return nil
        }
        
        return trimmed
    }
}
