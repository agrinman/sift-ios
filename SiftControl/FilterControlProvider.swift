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
            completionHandler(.drop(withUpdateRules: false))
            return
        }

        let host = flow.url?.host
        
        do {
            var rule = try RuleManager().getRule(for: app, hostname: host)
            
            if rule == nil {
                fireNotification(app: app, hostname: host)
            }
            
            DispatchQueue.global().async {
                while rule == nil {
                    Darwin.sleep(1)
                    do {
                        rule = try RuleManager().getRule(for: app, hostname: host)
                    } catch {
                        continue
                    }
                }
                
                if rule!.isAllowed {
                    completionHandler(.allow(withUpdateRules: false))
                } else {
                    completionHandler(.drop(withUpdateRules: false))
                }
            }

        } catch {
            completionHandler(.allow(withUpdateRules: false))
        }
        
    }
    
    func fireNotification(app:String, hostname:String?) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = Constants.notificationCategory
        content.userInfo = ["app": app, "host": hostname ?? "none"]
        content.title = "Incoming Network Request"
        
        let appComponents = app.components(separatedBy: ".")
        if let commonName = appComponents.last, appComponents.count > 1 {
            content.subtitle = "\(commonName) (\(app))"
        } else {
            content.subtitle = app
        }
        
        content.body = hostname ?? "No hostname"
        content.threadIdentifier = app
        
        let id = uniqueIdentifier(of: app, hostname ?? "none")
        
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


