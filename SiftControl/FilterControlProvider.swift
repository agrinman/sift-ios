//
//  FilterControlProvider.swift
//  SiftControl
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import NetworkExtension
import UserNotifications

class FilterControlProvider: NEFilterControlProvider {
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required
        guard  let app = flow.sourceAppIdentifier
        else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        guard let host = flow.getHost() else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        do {
            let id = uniqueIdentifier(of: app, host)
            try NetCache(appIdentifier: app).cache.setObject(host as NSString, forKey: id)

            guard let rule = try RuleManager().getRule(for: app, hostname: host) else {
                fireNotification(app: app, hostname: host)
                try RuleManager().create(rule: Rule(ruleType: RuleType.hostFromApp(host: host, app: app), isAllowed: true))
                completionHandler(.allow(withUpdateRules: true))
                return
            }
            
            if !(UserDefaults.group?.bool(forKey: Constants.pushActivityKey) ?? false) {
                fireNotification(app: app, hostname: host)
            }
            
            let verdict:NEFilterControlVerdict = rule.isAllowed ? .allow(withUpdateRules: false) : .drop(withUpdateRules: false)
            completionHandler(verdict)
            
        } catch {
            fireErrorNotification(error: "\(error)")
            completionHandler(.allow(withUpdateRules: false))
        }
        
    }
    
    func fireNotification(app:String, hostname:String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notes in
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = Constants.notificationCategory
            content.userInfo = ["app": app, "host": hostname]            
            content.body = app
            content.title = hostname
            content.threadIdentifier = app
            
            let id = UUID().uuidString
            
            let note = UNNotificationRequest(identifier: id,
                                             content: content,
                                             trigger: nil)
            
            
            UNUserNotificationCenter.current().add(note) { (err) in
                if err != nil {
                    print("err: \(err!)")
                }
            }
        }
        
    }
    
    func fireErrorNotification(error:String) {
        let content = UNMutableNotificationContent()
        content.title = "Error Showing Request"
        content.body = error
    
        
        let note = UNNotificationRequest(identifier: "sift_error_\(Date().timeIntervalSinceNow)",
                                         content: content,
                                         trigger: nil)
        
        UNUserNotificationCenter.current().add(note) { (err) in
            if err != nil {
                print("err: \(err!)")
            }
        }
    }
}


