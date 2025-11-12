//
//  SearchViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/11/25.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [SearchResponse.SearchItem] = []
    var onSelect: ((SearchResponse.SearchItem) -> Void)?
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(_ textfield: UITextField) {
        let query = (textfield.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 1 else {
            items.removeAll()
            tableView.reloadData()
            return
        }
        
        Task {
            await search(query: query)
        }
    }
    
    func search(query: String) async {
        do {
            
            let id = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_ID") as? String ?? ""
            let secret = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_SECRET") as? String ?? ""
            
            let cureentText = searchTextField.text ?? ""
            let result = try await NaverLocalSearch().search(query: cureentText, clientId: id, clientSecret: secret)
            
            DispatchQueue.main.async {
                self.items = result
                self.tableView.reloadData()
            }
        } catch {
            DispatchQueue.main.async {
                print("search error", error)
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = stripHTML(item.title)
        cell.detailTextLabel?.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onSelect?(item) // 값을 전달
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textDidChange(textField)
        textField.resignFirstResponder()
        return true
    }
}

func stripHTML(_ s: String) -> String {
    s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
}
