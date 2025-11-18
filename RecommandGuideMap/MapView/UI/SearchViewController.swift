//
//  SearchViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/11/25.
//

import UIKit

/// 네이버 지역 검색을 수행하고 결과를 테이블뷰로 보여주는 뷰 컨트롤러
///
/// - 검색어를 입력하면 네이버 지역 검색 API를 호출해 결과를 가져온다.
/// - 셀을 선택하면 `onSelect` 클로저를 통해 선택된 `SearchItem`을 상위 화면으로 전달한다.
class SearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /// 현재 검색 결과 리스트
    var items: [SearchResponse.SearchItem] = []
    
    /// 검색 결과 중 하나를 선택했을 때 선택된 아이템을 전달하는 콜백 클로저
    ///
    /// - Parameter item: 사용자가 선택한 `SearchResponse.SearchItem`
    var onSelect: ((SearchResponse.SearchItem) -> Void)?
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /// 뷰가 메모리에 로드된 직후 호출된다.
    ///
    /// - 초기 포커스를 검색 텍스트 필드에 주고
    /// - 텍스트 변경 이벤트(`.editingChanged`)가 발생했을 때 `textDidChange`가 호출되도록 연결한다.
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    /// 텍스트필드의 내용이 변경될 때마다 호출되는 메서드
    ///
    /// - Parameter textfield: 변경 이벤트가 발생한 `UITextField`
    /// - 공백을 제거한 후 글자가 1개 미만이면 결과를 비우고 반환한다.
    /// - 그 외에는 비동기로 `search(query:)`를 호출해 검색을 수행한다.
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
    /// 네이버 지역 검색 API를 호출해 검색을 수행하는 메서드
    ///
    /// - Parameter query: 검색어 문자열
    /// - Note:
    ///   - 실제 요청은 `SearchModel().search(keyword:)` 에서 수행한다.
    ///   - 메인 스레드에서 `items`와 `tableView`를 갱신한다.
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
    
    /// 각 행에 표시할 셀을 구성
    ///
    /// - 셀의 `textLabel`에는 가공된 장소 제목(HTML 태그 제거 후)을,
    /// - `detailTextLabel`에는 도로명 주소가 있으면 도로명, 없으면 지번 주소를 넣는다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = stripHTML(item.title)
        cell.detailTextLabel?.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    /// - 선택된 `SearchItem`을 `onSelect` 클로저로 전달하고, 화면 전환은 상위에서 처리한다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onSelect?(item) // 값을 전달
    }
}

extension SearchViewController: UITextFieldDelegate {
    /// 키보드의 리턴 키가 눌렸을 때 호출
    ///
    /// - `textDidChange(_:)` 를 한 번 호출해 최신 텍스트로 검색을 수행하고
    /// - 키보드를 내리기 위해 `resignFirstResponder()`를 호출한다.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textDidChange(textField)
        textField.resignFirstResponder()
        return true
    }
}

/// HTML 태그를 제거한 문자열을 반환하는 유틸리티 함수
///
/// - Parameter s: 원본 문자열
/// - Returns: `<태그>` 형식의 HTML 태그가 제거된 문자열
func stripHTML(_ s: String) -> String {
    s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
}
