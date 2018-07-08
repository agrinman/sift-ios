//
//  ViewController.swift
//  Sift
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import UIKit
import NetworkExtension
import UserNotifications

class FilterSettingsController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var enabledSwitch:UISwitch!
    @IBOutlet weak var enabledLabel:UILabel!
    @IBOutlet weak var pushControl:UISegmentedControl!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var resetButton:UIButton!


    var rules:[(AppName, [Rule])] = []
    var filteredRules:[(AppName, [Rule])] = []

    var isSearching:Bool = false
    
    var timer:Timer?
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setNavLogo()
        
        refresh.tintColor = AppColors.background.color
        refresh.addTarget(self, action: #selector(FilterSettingsController.reload), for: .valueChanged)
        tableView.refreshControl = refresh
        
        if UserDefaults.group?.bool(forKey: Constants.pushActivityKey) == true {
            pushControl.selectedSegmentIndex = 1
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        if let font = UIFont(name: "FiraSans-Regular", size: 16) {
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
                NSAttributedStringKey.font.rawValue: font,
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
            ]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Filter apps and hosts", attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.lightGray])
            
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(FilterSettingsController.reload), name: Constants.ObservableNotification.appBecameActive.name, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NEFilterManager.shared().loadFromPreferences { error in
            if let loadError = error {
                self.enabledSwitch.isOn = false
                self.enabledLabel.text = self.enabledSwitch.isOn ? "Enabled" : "Disabled"
                self.showWarning(title: "Error loading preferences", body: "\(loadError)")
                
                return
            }
            
            self.enabledSwitch.isOn = NEFilterManager.shared().isEnabled
            self.enabledLabel.text = self.enabledSwitch.isOn ? "Enabled" : "Disabled"

        }
        
        loadRules()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: Constants.onboardingKey) {
            self.showOnboarding()
            return
        }
        
        // ensure push enabled
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                return
            }
            
            if UserDefaults.standard.bool(forKey: "push_dnd") {
                return
            }
            
            self.showSettings(with: "Push Notifications",
                              message: "Push notifications are needed to show you incoming network requests while you're in another app.",
                              dnd: "push_dnd")
        }
    }
    
    func showOnboarding() {
        DispatchQueue.main.async {
            let onboardingController = Storyboard.Onboarding.instantiateInitialViewController()!
            self.present(onboardingController, animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.ObservableNotification.appBecameActive.name, object: nil)
    }
    
    @IBAction func pushActivitySettingChanged(sender: UISegmentedControl) {
        let newActivity = sender.selectedSegmentIndex == 0 ? false : true;
        UserDefaults.group?.set(newActivity, forKey: Constants.pushActivityKey)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterRulesFor(searchText: searchText.lowercased())
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterRulesFor(searchText:String) {
        if searchText.isEmpty {
            filteredRules = []
            isSearching = false
            self.tableView.reloadData()
            return
        }
 
        isSearching = true
        
        filteredRules = []
        
        for (app, rules) in rules {
            if app.contains(searchText) {
                filteredRules.append((app, rules))
                continue
            }
            
            var filteredAppRules:[Rule] = []
            for rule in rules {
                if case .hostFromApp(let host) = rule.ruleType, host.host.contains(searchText) {
                    filteredAppRules.append(rule)
                }
            }
            
            if !filteredAppRules.isEmpty {
                filteredRules.append((app, filteredAppRules))
            }
        }
        
        self.tableView.reloadData()
    }
    
    @objc func reload() {
        self.loadRules()
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        self.loadRules()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowAppRules") {
            guard let appNameCell = sender as? AppNameCell,
                let cellIndex = tableView.indexPath(for: appNameCell)
                else {
                    print("Sender is not as expected when showing app rules: \(String(describing: sender))")
                    return
            }
            let shownAppRules = isSearching ? filteredRules : rules
            let rule: (AppName, [Rule]) = shownAppRules[cellIndex.row]
            let dest = segue.destination as! AppRulesController
            dest.appName = rule.0
            dest.rules = rule.1
        }
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

            self.rules = newRules.sorted(by: { (r1, r2) -> Bool in
                return r1.0.commonName.localizedCompare(r2.0.commonName) == .orderedAscending
            })
            
            DispatchQueue.main.async {
                if self.rules.count == 2 {
                    self.resetButton.isHidden = true
                } else {
                    self.resetButton.isHidden = false
                }
                
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

    @IBAction func enableToggled() {
        enabledSwitch.isOn ? enable() : disable()
        enabledLabel.text = enabledSwitch.isOn ? "Enabled" : "Disabled"
    }
    
    @IBAction func clearAll() {
        try? RuleManager().deleteAll()
        self.loadRules()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rules = isSearching ? filteredRules : self.rules;

        if !isSearching && rules.count == 2 {
            return 1
        }

        return rules[section].1.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rules = isSearching ? filteredRules : self.rules;
        
        if !isSearching && rules.count == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyRulesCell")!
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RuleCell") as! RuleCell
        let rule = rules[indexPath.section].1[indexPath.row]
        cell.set(rule: rule)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if !isSearching && rules.count == 2 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rules = isSearching ? filteredRules : self.rules;

        let rule = rules[indexPath.section].1[indexPath.row]
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action, indexPath) in
            
            try? RuleManager().delete(rule: rule)
            self.loadRules()
        })
        
        deleteAction.backgroundColor = AppColors.deny.color

        var actions = [deleteAction]

        if rule.isAllowed {
            let action = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Drop", handler: { (action, indexPath) in
                
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
            action.backgroundColor = AppColors.allow.color
            actions.append(action)
        }
        
        return actions
    }
}

class AppNameCell: UITableViewCell {
    @IBOutlet weak var appNameLabel:UILabel!
}

