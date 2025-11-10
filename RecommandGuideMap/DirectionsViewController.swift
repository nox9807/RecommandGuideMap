//
//  DirectionsViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/7/25.
//

import UIKit

class DirectionsViewController: UIViewController {

    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var arriveTextField: UITextField!
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func changeText(_ sender: Any) {
        let changeText = startTextField.text
        let changePlaceholder = startTextField.placeholder
        startTextField.placeholder = arriveTextField.placeholder
        startTextField.text = arriveTextField.text
        arriveTextField.placeholder = changePlaceholder
        arriveTextField.text = changeText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
