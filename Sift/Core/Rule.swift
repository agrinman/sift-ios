//
//  Rule.swift
//  Sift
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation

struct Rule {
    let ruleType:RuleType
    let isAllowed:Bool
    let date:Date
}

extension Rule {
    init(ruleType:RuleType, isAllowed:Bool) {
        self.init(ruleType: ruleType, isAllowed: isAllowed, date: Date())
    }
}

enum RuleType {
    case host(String)
    case app(AppName)
    case hostFromApp(host:String, app:AppName)
}


typealias AppName = String
extension AppName {    
    var commonName:String {
        return self.components(separatedBy: ".").last ?? self
    }
}

struct Wildcard {
    let app:AppName
    let isAllowed:Bool
}

