//
//  FilterDataProvider.swift
//  SiftData
//
//  Created by Alex Grinman on 12/23/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required.
        
        guard   let app = flow.sourceAppIdentifier
        else {
            return .drop()
        }
        
        // temp: return all apple
        if app.hasPrefix(".com.apple") {
            return .allow()
        }
        
        do {
            guard let rule = try RuleManager().getRule(for: app, hostname: flow.url?.host)
            else {
                return .needRules()
            }
            
            return rule.isAllowed ? .allow() : .drop()

        } catch {
            return .needRules()
        }
    }
}
