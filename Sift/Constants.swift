//
//  Constants.swift
//  Sift
//
//  Created by Alex Grinman on 12/24/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation

struct Constants {
    static let appGroupIdentifier = "group.in.alexgr.Sift.shared"
    static let notificationCategory = "network_request_category"
    static let onboardingKey = "onboarding_key"
    static let pushActivityKey = "push_activity_key"

    enum NotificationAction:String {
        case edit = "network_request_edit_action"
        
        case allowThis = "network_request_allow_action"
        case allowHost = "network_request_allow_host_action"
        case allowApp = "network_request_allow_app_action"
        
        case denyThis = "network_request_deny_action"
        case denyHost = "network_request_deny_host_action"
        case denyApp = "network_request_deny_app_action"

        var id:String { return self.rawValue }
    }
    
    enum ObservableNotification {
        case appBecameActive
        case editAction
         
        var nameString:String {
            switch self {
            case .appBecameActive:
                return "app_became_active"
            case .editAction:
                return "edit_action"
            }
        }
        
        var name:NSNotification.Name {
            return NSNotification.Name(rawValue: nameString)
        }
    }
    
    static let appURL:String = "https://getsift.app"
    static let promoText:String = "Sift uncovers what apps are really doing on your phone."
    
    enum WebsiteEndpoints:String {
        case faq = "faq"
        case privacy = "privacy"
        case developer = "developer"
        
        var url:String {
            return "\(Constants.appURL)/\(self.rawValue)"
        }
    }

}

extension UserDefaults {
    static var  group:UserDefaults? {
        return UserDefaults(suiteName: Constants.appGroupIdentifier)
    }
}

func dispatchAfter(delay:Double, task:@escaping ()->Void) {
    
    let delay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: delay) {
        task()
    }
}

