//
//  DamagePickerViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/20.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit

class DamagePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let damages = ["裂痕", "植物性破壞"]
    var selectedIndex: Int = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return damages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return damages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row;
    }
}
