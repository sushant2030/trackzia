//
//  RBOptionItem.swift
//  Demo
//
//  Created by pranav on 21/04/18.
//  Copyright © 2018 RB. All rights reserved.
//

import UIKit

protocol RBOptionItem {
    var text: String { get }
    var isSelected: Bool { get set }
    var font: UIFont { get set }
}

extension RBOptionItem {    
    func sizeForDisplayText() -> CGSize {
        return text.size(withAttributes: [NSAttributedString.Key.font: font])
    }
}
