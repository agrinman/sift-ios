//
//  NotificationViewController.swift
//  NotifyUI
//
//  Created by Alex Grinman on 12/27/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    var networkRuleController:NetworkRuleController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard   notification.request.content.categoryIdentifier == Constants.notificationCategory,
            let app = notification.request.content.userInfo["app"] as? String,
            let host = notification.request.content.userInfo["host"] as? String
        else {
                return
        }
        
        self.networkRuleController?.appIdentifier = app
        self.networkRuleController?.addHosts(newHosts: [host])

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let netController = segue.destination as? NetworkRuleController {
            self.networkRuleController = netController
            netController.isNotificationUI = true
        }
    }

}
