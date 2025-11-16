//
//  DirectionsViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/7/25.
//

import UIKit

class DirectionsViewController: UIViewController {

    enum SearchType {
        case start
        case arrive
    }
    var currentSearchType: SearchType?
    var startItem: SearchResponse.SearchItem?
    var arriveItem: SearchResponse.SearchItem?
    var mapView: MapViewController!
    var searchResult: [SearchResponse.SearchItem] = []
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var arriveTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        UIUpdate()
        
        startTextField.delegate = self
        arriveTextField.delegate = self
        startTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        arriveTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func UIUpdate() {
        if let startItem {
            startTextField.text = stripHTML(startItem.title)
            _ = startItem.roadAddress.isEmpty ? startItem.address : startItem.roadAddress
        }
        
        if let arriveItem {
            arriveTextField.text = stripHTML(arriveItem.title)
            _ = arriveItem.roadAddress.isEmpty ? arriveItem.address : arriveItem.roadAddress
        }
    }
    
    @objc func textDidChange(_ textfield: UITextField) {
        let keyword = textfield.text ?? ""
        
        Task {
            do {
                let result = try await SearchModel().search(keyword: keyword)
                self.searchResult = result
                self.tableView.reloadData()
            } catch {
                print("Search error: \(error)")
            }
        }
    }
}

extension DirectionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        print("mapView:", mapView as Any)
        guard let startItem = startItem, let arriveItem = arriveItem else { return true }
        mapView.mapViewFocus(startMapx: startItem.mapx, startMapy: startItem.mapy, startTitle: startItem.title, arriveMapx: arriveItem.mapx, arriveMapy: arriveItem.mapy, arriveTitle: arriveItem.title)
        
        dismiss(animated: true)
        presentingViewController?.dismiss(animated: true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.isHidden = false
        searchResult.removeAll()
        tableView.reloadData()
        if textField == startTextField {
            currentSearchType = .start
        } else if textField == arriveTextField {
            currentSearchType = .arrive
        }
    }
}

extension DirectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = searchResult[indexPath.row]
        
        switch currentSearchType {
            case .start:
                startItem = selected
                startTextField.text = stripHTML(selected.title)
            case .arrive:
                arriveItem = selected
                arriveTextField.text = stripHTML(selected.title)
            default:
                break
        }
        
        tableView.isHidden = true
        view.endEditing(true)
    }
}

extension DirectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = searchResult[indexPath.row]
        
        cell.textLabel?.text = stripHTML(item.title)
        cell.detailTextLabel?.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
        
        return cell
    }
    
    
}
