//
//  AppRulesController.swift
//  Sift
//
//  Created by Ayush Goel on 08/07/18.
//  Copyright © 2018 Ayush Goel. All rights reserved.
//

import UIKit

class AppRulesController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  var appName: AppName!
  var rules: [Rule]!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setNavLogo()
  }
}

extension AppRulesController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rules.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RuleCell") as! RuleCell
    let rule = rules[indexPath.row]
    cell.set(rule: rule)
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.textColor = AppColors.background.color
    header.textLabel?.font = UIFont(name: "FiraSans-Bold", size: 20)
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return appName.capitalized
  }
}

extension AppRulesController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rule = rules[indexPath.row]

    switch rule.ruleType {
    case .app:
      return
    case .host:
      return
    case .hostFromApp(let host, let app):
      let alertController = UIAlertController(title: host, message: "Chose a network rule for this host.", preferredStyle: .actionSheet)

      if rule.isAllowed {
        alertController.addAction(UIAlertAction(title: "Drop for \(app.commonName)", style: .destructive, handler: { (action:UIAlertAction) -> Void in
          try? RuleManager().toggle(rule: rule)

          //                    self.loadRules()
        }))

        alertController.addAction(UIAlertAction(title: "Drop for all apps", style: .destructive, handler: { (action:UIAlertAction) -> Void in
          try? RuleManager().toggle(rule: rule)
          try? RuleManager().create(rule: Rule(ruleType: .host(host), isAllowed: false))
          //                    self.loadRules()
        }))
      } else {
        alertController.addAction(UIAlertAction(title: "Allow for \(app.commonName)", style: .destructive, handler: { (action:UIAlertAction) -> Void in
          try? RuleManager().toggle(rule: rule)
          //                    self.loadRules()
        }))

        alertController.addAction(UIAlertAction(title: "Allow for all apps", style: .destructive, handler: { (action:UIAlertAction) -> Void in
          try? RuleManager().toggle(rule: rule)
          try? RuleManager().create(rule: Rule(ruleType: .host(host), isAllowed: true))
          //                    self.loadRules()
        }))
      }

      alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in

      }))

      self.present(alertController, animated: true, completion: nil)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

class RuleCell: UITableViewCell {
  @IBOutlet weak var valueLabel:UILabel!
  @IBOutlet weak var allowedLabel:UILabel!

  func set(rule:Rule) {
    if rule.isAllowed {
      allowedLabel.text = "Allow"
      allowedLabel.textColor = AppColors.allow.color
    } else {
      allowedLabel.text = "Drop"
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
