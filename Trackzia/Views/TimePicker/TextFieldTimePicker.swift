//
//  TextFieldTimePicker.swift
//  Trackzia
//
//  Created by Rohan Bhale on 04/02/19.
//  Copyright © 2019 Private. All rights reserved.
//

import UIKit

class TextFieldTimePicker: UIView {
    @IBOutlet var pickerView: UIPickerView!
    
    var selectionHandler: ((Int, Int) -> Void)?
    var cancelHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        let bundle = Bundle(for: TextFieldTimePicker.self)
        let xib = bundle.loadNibNamed("TextFieldTimePicker", owner: self, options: nil)!
        let containerView = xib.first! as! UIView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        let views:[String: Any] = ["containerView": containerView]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: views)
        self.addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: views)
        self.addConstraints(vConstraints)

    }
    
    @IBAction func selectButtonTouched() {
        selectionHandler?(pickerView.selectedRow(inComponent: 0), pickerView.selectedRow(inComponent: 1))
    }
    
    @IBAction func cancelButtonTouched() {
        cancelHandler?()
    }
}

extension TextFieldTimePicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return 24 }
        return 60
    }
}

extension TextFieldTimePicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return String(format: "%02d", row) }
        return String(format: "%02d", row)
    }
}
