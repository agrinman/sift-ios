//
//  Flow.swift
//  Sift
//
//  Created by Alex Grinman on 12/30/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import NetworkExtension

extension NEFilterFlow {
    func getHost() -> String? {
        if let host = self.url?.host {
            return host
        }
        
        switch self {
        case let browserFlow as NEFilterBrowserFlow:
            return browserFlow.request?.url?.absoluteString
        case let socketFlow as NEFilterSocketFlow:
            var endpoint = "unknown"
            if let neEndpoint = socketFlow.remoteEndpoint {
                endpoint = "\(neEndpoint)"
            }

            return "socket: \(endpoint)"
        default:
            return nil
        }

    }
}
