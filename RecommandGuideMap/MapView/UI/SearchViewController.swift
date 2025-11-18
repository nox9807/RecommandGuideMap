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
    // 여기부분 여러번 호출되니까 고려해볼 것 끝글자에 맞춰서 앞글자는 캔슬되게 아니면 타이핑중인 상태를 받아 타이핑을 하지않는 시간을(0.5 ~ 1) 정해 타이핑중에는 검색이되지않고 타이핑이 끝나면 search가 한번 불리게
    func search(query: String) async {
        do {
            let result = try await SearchModel().search(keyword: searchTextField.text ?? "")
            
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
