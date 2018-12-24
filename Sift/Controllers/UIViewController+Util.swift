//
//  UIViewController+Util.swift
//  Sift
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showWarning(title:String, body:String, then:(()->Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController:UIAlertController = UIAlertController(title: title, message: body,
                                                                      preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) -> Void in
                then?()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showSettings(with title:String, message:String, dnd:String? = nil, then:(()->Void)? = nil) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
            
            then?()
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            then?()
        }
        alertController.addAction(cancelAction)
        
        if let dndKey = dnd {
            alertController.addAction(UIAlertAction(title: "Don't ask again", style: UIAlertAction.Style.destructive) { (action) in
                UserDefaults.standard.set(true, forKey: dndKey)
            })
            
        }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func askConfirmationIn(title:String, text:String, accept:String, cancel:String, handler: @escaping ((_ confirmed:Bool) -> Void)) {
        
        let alertController:UIAlertController = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
        
        
        alertController.addAction(UIAlertAction(title: accept, style: UIAlertAction.Style.default, handler: { (action:UIAlertAction) -> Void in
            
            handler(true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: { (action:UIAlertAction) -> Void in
            
            handler(false)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

