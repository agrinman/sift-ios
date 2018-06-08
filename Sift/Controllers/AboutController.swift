//
//  AboutController.swift
//  Sift
//
//  Created by Alex Grinman on 6/4/18.
//  Copyright © 2018 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit

class AboutController:UIViewController {
    @IBOutlet weak var versionLabel:UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setNavLogo()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(AboutController.shareTapped))
        
        if  let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "Version \(version)"
        }
    }
    
    @objc func shareTapped() {
        let link = Constants.appURL
        let text = Constants.promoText
        
        var items:[Any] = []
        items.append(text)
        
        if let urlItem = URL(string: link) {
            items.append(urlItem)
        }
        
        let share = UIActivityViewController(activityItems: items,
                                             applicationActivities: nil)
        
        
        share.completionWithItemsHandler = { (_, _, _, _) in
            self.dismiss(animated: true, completion: nil)
        }
        
        self.present(share, animated: true, completion: nil)

    }
    
    func openURL(url string:String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func faqTapped() {
        openURL(url: Constants.WebsiteEndpoints.faq.url)
    }
    
    @IBAction func privacyTapped() {
        openURL(url: Constants.WebsiteEndpoints.privacy.url)
    }
    
    @IBAction func developerTapped() {
        openURL(url: Constants.WebsiteEndpoints.developer.url)
    }
}
