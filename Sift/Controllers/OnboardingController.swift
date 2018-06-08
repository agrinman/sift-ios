//
//  OnboardingController.swift
//  Sift
//
//  Created by Alex Grinman on 1/4/18.
//  Copyright © 2018 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit
import NetworkExtension
import UserNotifications

class OBNetworkPermissionsController:UIViewController {
    
    @IBOutlet weak var enabledNetSwitch:UISwitch!
    @IBOutlet weak var enabledPushSwitch:UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // net
        NEFilterManager.shared().loadFromPreferences { error in
            if let _ = error {
                self.enabledNetSwitch.isOn = false
                return
            }
            
            DispatchQueue.main.async {
                self.enabledNetSwitch.isOn = NEFilterManager.shared().isEnabled
            }
            
            
            // push
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.enabledPushSwitch.isOn = true
                    }
                }
                
                DispatchQueue.main.async {
                    if self.enabledNetSwitch.isOn && self.enabledPushSwitch.isOn {
                        self.performSegue(withIdentifier: "showTutorial", sender: nil)
                    }
                }                
            }
        }
    }
    
    @IBAction func enableNetFilterToggled() {
        if NEFilterManager.shared().providerConfiguration == nil {
            let newConfiguration = NEFilterProviderConfiguration()
            newConfiguration.username = "Sift"
            newConfiguration.organization = "Sift App"
            newConfiguration.filterBrowsers = true
            newConfiguration.filterSockets = true
            NEFilterManager.shared().providerConfiguration = newConfiguration
        }
        
        NEFilterManager.shared().isEnabled = true
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.showWarning(title: "Error Enabling Filter", body: "\(err)")
            }
            
            DispatchQueue.main.async {
                self.enabledNetSwitch.isOn = true
            }
        }
    }
    
    
    @IBAction func enablePushToggled() {
        (UIApplication.shared.delegate as? AppDelegate)?.registerForNotifications(completion: { error in
            guard error == nil else {
                self.showWarning(title: "Error", body: "\(error!)")
                return
            }
            
            DispatchQueue.main.async {
                self.enabledPushSwitch.isOn = true
                self.performSegue(withIdentifier: "showTutorial", sender: nil)
            }
            
        })
    }
    
}


class OBTutorialController:UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()        
        UserDefaults.standard.set(true, forKey: Constants.onboardingKey)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func startTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}


