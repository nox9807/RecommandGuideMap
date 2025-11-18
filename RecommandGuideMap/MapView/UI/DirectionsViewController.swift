//
//  DirectionsViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/7/25.
//

import UIKit

/// 출발지/도착지를 검색해서 선택하고,
/// 선택된 두 지점을 `MapViewController`에 넘겨
/// 지도에 경로를 표시하도록 요청하는 화면.
class DirectionsViewController: UIViewController {
    
    /// 어떤 텍스트 필드에서 검색 중인지 나타내는 타입.
    enum SearchType {
        case start
        case arrive
    }
    
    /// 현재 포커스된 검색 타입(출발/도착).
    var currentSearchType: SearchType?
    
    /// InfoViewController에서 전달된 출발지 아이템.
    var startItem: SearchResponse.SearchItem?
    
    /// InfoViewController에서 전달된 도착지 아이템.
    var arriveItem: SearchResponse.SearchItem?
    
    /// 실제 지도를 관리하는 상위 MapViewController.
    /// 여기로 선택된 출발/도착 좌표를 넘긴다.
    var mapView: MapViewController!
    
    /// 실시간 검색 결과 리스트.
    var searchResult: [SearchResponse.SearchItem] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var arriveTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /// 상단 X 버튼. 길찾기 화면을 닫는다.
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /// ↕ 버튼. 출발지/도착지의 텍스트와 플레이스홀더를 서로 바꾼다.
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
        startTextField.becomeFirstResponder()
        
        UIUpdate()
        
        startTextField.delegate = self
        arriveTextField.delegate = self
        
        // 텍스트가 변경될 때마다 실시간 검색 수행
        startTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        arriveTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    /// InfoViewController에서 전달된 출발/도착 아이템을
    /// 텍스트 필드 UI에 반영한다.
    func UIUpdate() {
        if let startItem {
            startTextField.text = stripHTML(startItem.title)
        }
        
        if let arriveItem {
            arriveTextField.text = stripHTML(arriveItem.title)
        }
    }
    
    /// 출발/도착 텍스트 필드 내용이 바뀔 때마다 호출되어
    /// 네이버 로컬 검색 API로 장소를 검색한다.
    ///
    /// - Parameter textfield: 변경이 발생한 텍스트 필드.
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

// MARK: - UITextFieldDelegate

extension DirectionsViewController: UITextFieldDelegate {
    /// 키보드에서 리턴(검색) 키를 눌렀을 때 호출된다.
    ///
    /// 출발/도착 아이템이 모두 설정되어 있으면
    /// `mapView.mapViewFocus`를 호출하여 지도에 경로를 표시한 뒤,
    /// 현재 길찾기 화면과 그 아래 InfoViewController를 모두 닫는다.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let startItem = startItem, let arriveItem = arriveItem else { return true }
        
        mapView.selectedItem = nil
        
        mapView.mapViewFocus(points: [
            (mapx: startItem.mapx, mapy: startItem.mapy, title: startItem.title),
            (mapx: arriveItem.mapx, mapy: arriveItem.mapy, title: arriveItem.title)
        ])
        
        // Directions 닫고, 그 아래 InfoViewController도 함께 닫기
        dismiss(animated: true)
        presentingViewController?.dismiss(animated: true)
        return true
    }
    
    /// 텍스트 필드 편집이 시작될 때 호출된다.
    ///
    /// - 어떤 필드가 활성화되었는지에 따라 `currentSearchType`을 설정하고
    /// - 기존 검색 결과를 초기화한 뒤, 테이블을 다시 보여준다.
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

// MARK: - UITableViewDelegate
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
