//
//  Resources.swift
//  Sift
//
//  Created by Alex Grinman on 12/28/17.
//  Copyright © 2017 Alex Grinman. All rights reserved.
//

import Foundation
import UIKit

class OutlinedButton:UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var highlightedColor:UIColor = UIColor.white
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let originalColor = backgroundColor {
            backgroundColor = highlightedColor
            borderColor = highlightedColor
            highlightedColor = originalColor
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let highlight = backgroundColor {
            backgroundColor = highlightedColor
            borderColor = highlight
            highlightedColor = highlight
        }
    }
}
