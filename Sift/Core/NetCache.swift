//
//  NetCache.swift
//  Sift
//
//  Created by Alex Grinman on 12/28/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import AwesomeCache

class NetCache {
    
    let appIdentifier:String
    let cache:Cache<NSString>
    
    enum Errors:Error {
        case missingSharedGroupDirectory
    }
    
    init(appIdentifier:String) throws {
        self.appIdentifier = appIdentifier
        
        guard let groupDirectory = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)?
            .appendingPathComponent("cache_\(appIdentifier)")
        else {
            throw Errors.missingSharedGroupDirectory
        }

        self.cache = try Cache<NSString>(name: appIdentifier, directory: groupDirectory)
    }
}
