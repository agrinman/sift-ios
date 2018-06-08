//
//  UniqueID.swift
//  Sift
//
//  Created by Alex Grinman on 12/24/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import CommonCrypto

func uniqueIdentifier(of attrs:String...) -> String {
    var input = ""
    attrs.forEach {
        input += $0.SHA256.hex
    }
    
    return String(input.SHA256.hex.suffix(16))
}

