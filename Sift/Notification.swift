//
//  Notification.swift
//  Sift
//
//  Created by Alex Grinman on 12/24/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard   response.notification.request.content.categoryIdentifier == Constants.notificationCategory,
                let app = response.notification.request.content.userInfo["app"] as? String
        else {
            completionHandler()
            return
        }
        
        var rule:Rule

        guard let action = Constants.NotificationAction(rawValue: response.actionIdentifier)
        else {
            print("unknown action: \(response.actionIdentifier)")
            completionHandler()
            showEditController(for: app)
            return

        }
        
        switch action {
        case .edit:
            completionHandler()
            return
            
        case .allowApp:
            rule = Rule(ruleType: .app(app), isAllowed: true)
            
        case .denyApp:
            rule = Rule(ruleType: .app(app), isAllowed: false)

        default:
            print("unknown action response: \(response.actionIdentifier)")
            completionHandler()
            return
        }
        
        do {
            try RuleManager().create(rule: rule)
            try NetCache(appIdentifier: app).cache.removeAllObjects()
            AppDelegate.removeNotifications(for: app)
        } catch {
            print("error saving rule: \(error)")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func showEditController(for appIdentifier:String) {
        NotificationCenter.default.post(name: Constants.ObservableNotification.editAction.name, object: appIdentifier)
    }
    
    static func removeNotifications(for appIdentifier:String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notes in
            let ids = notes.filter { $0.request.content.threadIdentifier == appIdentifier }.map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}
class Notifications {
    static var authorizeCategory:UNNotificationCategory = {
        return UNNotificationCategory(identifier: Constants.notificationCategory,
                                      actions: [Notifications.edit,
                                                Notifications.denyAllApp],
                                      intentIdentifiers: [],
                                      hiddenPreviewsBodyPlaceholder: "Incoming network request",
                                      options: .customDismissAction)
    }()
    
    
    static var edit:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.NotificationAction.edit.id,
                                    title: "Edit rules",
                                    options: .foreground)
    }()
    
    static var denyAllApp:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.NotificationAction.denyApp.id,
                                    title: "Drop all for this app",
                                    options: .destructive)
    }()


}
