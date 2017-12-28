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
                let app = response.notification.request.content.userInfo["app"] as? String,
                let host = response.notification.request.content.userInfo["host"] as? String
        else {
            completionHandler()
            return
        }
        
        var rule:Rule
        
        switch response.actionIdentifier {
        case Constants.notificationAllowIdentifier:
            rule = Rule(ruleType: .hostFromApp(host: host, app: app), isAllowed: true)
            
        case Constants.notificationAllowHostIdentifier:
            rule = Rule(ruleType: .host(host), isAllowed: true)
        
        case Constants.notificationAllowAppIdentifier:
            rule = Rule(ruleType: .app(app), isAllowed: true)

        case Constants.notificationDenyIdentifier:
            rule = Rule(ruleType: .hostFromApp(host: host, app: app), isAllowed: false)
            
        case Constants.notificationDenyHostIdentifier:
            rule = Rule(ruleType: .host(host), isAllowed: false)
            
        case Constants.notificationDenyAppIdentifier:
            rule = Rule(ruleType: .app(app), isAllowed: false)

        default:
            print("unknown action response: \(response.actionIdentifier)")
            completionHandler()
            return
        }
        
        do {
            try RuleManager().create(rule: rule)
        } catch {
            print("error saving rule: \(error)")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
}
class Notifications {
    static var authorizeCategory:UNNotificationCategory = {
        return UNNotificationCategory(identifier: Constants.notificationCategory,
                                      actions: [Notifications.approve,
                                                Notifications.approveAllHost,
                                                Notifications.approveAllApp,
                                                Notifications.deny,
                                                Notifications.denyAllHost,
                                                Notifications.denyAllApp],
                                      intentIdentifiers: [],
                                      hiddenPreviewsBodyPlaceholder: "Incoming network request. Tap to allow/deny.",
                                      options: .customDismissAction)
    }()
    
    
    static var approve:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationAllowIdentifier,
                                    title: "Allow this only",
                                    options: .authenticationRequired)
    }()
    
    static var approveAllHost:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationAllowHostIdentifier,
                                    title: "Allow this host for all apps",
                                    options: .authenticationRequired)
    }()
    
    static var approveAllApp:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationAllowAppIdentifier,
                                    title: "Whitelist app",
                                    options: .authenticationRequired)
    }()


    static var deny:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationDenyIdentifier,
                                    title: "Deny for this app",
                                    options: .destructive)
    }()

    static var denyAllHost:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationDenyHostIdentifier,
                                    title: "Deny this host for all apps",
                                    options: .destructive)
    }()
    
    static var denyAllApp:UNNotificationAction = {
        return UNNotificationAction(identifier: Constants.notificationDenyAppIdentifier,
                                    title: "Blacklist app",
                                    options: .destructive)
    }()


}
