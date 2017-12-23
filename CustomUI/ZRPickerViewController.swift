//
//  ZRPickerViewController.swift
//  CustomUI
//
//  Created by Chen Zerui on 23/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

fileprivate let bundle = Bundle(for: ZRPickerViewController.self)

public class ZRPickerViewController: UIViewController{
    
    public init(options: [String], selected: Int) {
        self.originalSelection = selected
        self.options = options
        self.selectedIndex = selected
        super.init(nibName: "ZRPickerViewController", bundle: bundle)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var onSelection: ((Int)->Void)?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectOriginalButton: UIBarButtonItem!
    
    let originalSelection: Int
    var options: [String]
    var selectedIndex: Int

    override public func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(originalSelection, inComponent: 0, animated: false)
    }
    
    @IBAction func selectOriginal() {
        pickerView.selectRow(originalSelection, inComponent: 0, animated: true)
    }
    
    @IBAction func completeSelection() {
        dismiss(animated: true){
            self.onSelection?(self.selectedIndex)
        }
    }
    
    @IBAction func emptyAreaTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
}

extension ZRPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        selectOriginalButton.isEnabled = selectedIndex != originalSelection
    }
    
}
