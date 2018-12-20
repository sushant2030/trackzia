//
//  UITableViewCellOptionItemUtility.swift
//  Demo
//
//  Created by pranav on 21/04/18.
//  Copyright © 2018 RB. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func configure(with optionItem: RBOptionItem) {
        textLabel?.text = optionItem.text
        textLabel?.font = optionItem.font
        accessoryType = optionItem.isSelected ? .checkmark : .none
    }
}
