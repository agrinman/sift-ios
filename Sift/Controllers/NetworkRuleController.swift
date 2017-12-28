//
//  NetworkRuleOptionsController.swift
//  Sift
//
//  Created by Alex Grinman on 12/28/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit

class NetworkRuleController:UITableViewController {
    
    @IBOutlet weak var doneButton:UIButton!
    
    @IBOutlet weak var appNameLabel:UILabel!
    @IBOutlet weak var appIdentifierLabel:UILabel!

    private var hosts:[(String, Bool)] = []
    var appIdentifier:String?
    
    var hostMap:[String:Bool] = [:]
    
    var isNotificationUI:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNotificationUI {
            self.tableView.tableFooterView = UIView()
            self.doneButton.isHidden = true
        }
    }
    
    func set(appIdentifier:String) {
        guard self.appIdentifier == nil else {
            return
        }
        
        appIdentifierLabel.text = appIdentifier
        appNameLabel.text = appIdentifier?.commonName.capitalized
        self.appIdentifier = appIdentifier
    }
    
    func addHosts(newHosts:[String]) {
        for host in newHosts {
            guard hostMap[host] == nil else {
                continue
            }
            
            hosts.append((host, true))
            hostMap[host] = true
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // tabelview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkRuleCell") as! NetworkRuleCell
        let host = hosts[indexPath.row]
        cell.set(host: host.0, isSelected: host.1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let host = hosts[indexPath.row]
        hosts[indexPath.row] = (host.0, !host.1)
        self.tableView.reloadData()
    }

    
    // actions
    
    @IBAction func setRulesTapped() {
        
    }
    
}

class NetworkRuleCell:UITableViewCell {
    @IBOutlet var hostNameLabel:UILabel!
    
    func set(host:String, isSelected:Bool) {
        hostNameLabel.text = host
        
        if isSelected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }
    
}

