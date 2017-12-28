//
//  ViewController.swift
//  Sift
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import UIKit
import NetworkExtension

enum AppColors:Int {
    case highlight = 0x23FFCE
    case deny = 0xFF7B98
    case background = 0x232323

    var color:UIColor {
        return UIColor(hex: self.rawValue)
    }
}

class FilterSettingsController: UITableViewController {

    @IBOutlet weak var enabledSwitch:UISwitch!
    @IBOutlet weak var enabledLabel:UILabel!
    @IBOutlet weak var passiveActiveSegmentedControl:UISegmentedControl!

    var rules:[(AppName, [Rule])] = []
    
    var timer:Timer?
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh.tintColor = AppColors.highlight.color
        refresh.addTarget(self, action: #selector(FilterSettingsController.reload), for: .valueChanged)
        tableView.refreshControl = refresh
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        if let font = UIFont(name: "FiraSans-Regular", size: 16) {
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NEFilterManager.shared().loadFromPreferences { error in
            if let loadError = error {
                self.enabledSwitch.isOn = false
                self.showWarning(title: "Error loading preferences", body: "\(loadError)")
                
                return
            }
            
            self.enabledSwitch.isOn = NEFilterManager.shared().isEnabled
        }
        
        loadRules()

    }
    
    @objc func reload() {
        self.loadRules()
    }
    
    func loadRules() {
        do {
            let rulesList = try RuleManager().fetchAll()
            
            var appHostRules:[String: [Rule]] = [:]
            var appRules:[Rule] = []
            var hostRules:[Rule] = []
            
            for rule in rulesList {
                switch rule.ruleType {
                case .app:
                    appRules.append(rule)
                case .host:
                    hostRules.append(rule)
                case .hostFromApp(_, let app):
                    if let existingRules = appHostRules[app] {
                        let newRules = existingRules + [rule]
                        appHostRules[app] = newRules
                        
                        continue
                    }
                    
                    appHostRules[app] = [rule]
                }
            }
            
            var newRules = [(String, [Rule])]()
            
            appHostRules.forEach {
                newRules.append(($0.key, $0.value))
            }
            
            newRules.append(("App Rules", appRules))
            newRules.append(("Host Rules", hostRules))
            
            self.rules = newRules
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }
            
        } catch {
            self.showWarning(title: "Error loading rules", body: "\(error)")
        }

    }
    
    func enable() {
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
        }
    }
    
    func disable() {
        NEFilterManager.shared().isEnabled = false
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.showWarning(title: "Error Disabling Filter", body: "\(err)")
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func enableToggled() {
        enabledSwitch.isOn ? enable() : disable()
        enabledLabel.text = enabledSwitch.isOn ? "Enabled" : "Disabled"
    }
    
    @IBAction func clearAll() {
        try? RuleManager().deleteAll()
        self.loadRules()
    }

    // MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rules.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = AppColors.highlight.color
        header.textLabel?.font = UIFont(name: "FiraSans-Bold", size: 16)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = AppColors.highlight.color.withAlphaComponent(0.5)
        header.textLabel?.font = UIFont(name: "FiraSans-Regular", size: 10)
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if rules[section].1.isEmpty {
            return ""
        }
        
        return rules[section].0.commonName
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if rules[section].1.isEmpty {
            return ""
        }
        
        return rules[section].0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rules[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RuleCell") as! RuleCell
        let rule = rules[indexPath.section].1[indexPath.row]
        cell.set(rule: rule)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rule = rules[indexPath.section].1[indexPath.row]
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Remove", handler: { (action, indexPath) in
            
            try? RuleManager().delete(rule: rule)
            self.loadRules()
        })
        
        deleteAction.backgroundColor = AppColors.deny.color

        var actions = [deleteAction]

        if rule.isAllowed {
            let action = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Deny", handler: { (action, indexPath) in
                
                try? RuleManager().toggle(rule: rule)
                self.loadRules()
            })
            action.backgroundColor = AppColors.deny.color
            actions.append(action)
        } else {
            let action = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Allow", handler: { (action, indexPath) in
                
                try? RuleManager().toggle(rule: rule)
                self.loadRules()
            })
            action.backgroundColor = AppColors.highlight.color
            actions.append(action)
        }
        
        return actions
    }
    
}

class RuleCell:UITableViewCell {
    @IBOutlet weak var valueLabel:UILabel!
    @IBOutlet weak var allowedLabel:UILabel!
    
    func set(rule:Rule) {
        if rule.isAllowed {
            allowedLabel.text = "ALLOW"
            allowedLabel.textColor = AppColors.highlight.color
        } else {
            allowedLabel.text = "DENY"
            allowedLabel.textColor = AppColors.deny.color
        }

        
        switch rule.ruleType {
        case .app(let app):
            valueLabel.text = app
            
        case .host(let host):
            valueLabel.text = host
            
        case .hostFromApp(let host, _):
            valueLabel.text = host
        }
    }
    
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

