//
//  NotificationScheduler.swift
//  Get2It
//
//  Created by Vici Shaweddy on 5/22/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationScheduler {
    func scheduleNotification(identifier: String, trigger: UNNotificationTrigger, title: String, sound: Bool)
}

extension NotificationScheduler {
    func scheduleNotification(identifier: String, trigger: UNNotificationTrigger, title: String, sound: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Starts in 10 minutes."
        if sound {
            content.sound = UNNotificationSound.default
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
