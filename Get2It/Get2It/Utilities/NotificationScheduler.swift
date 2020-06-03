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
    func scheduleNotification(trigger: UNNotificationTrigger, title: String, sound: Bool)
}

extension NotificationScheduler where Self: UIViewController {
    func scheduleNotification(trigger: UNNotificationTrigger, title: String, sound: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        if sound {
            content.sound = UNNotificationSound.default
        }
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    let message = "Failed to schedule notification. \(error.localizedDescription)"
                    UIAlertController.okWithMessage(message, presentingViewController: self)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
