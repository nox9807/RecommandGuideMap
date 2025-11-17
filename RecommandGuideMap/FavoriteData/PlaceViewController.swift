//
//  PlaceViewController.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/6/25.
//

import UIKit

class PlaceViewController: UIViewController {
    
        
    @IBOutlet weak var tableView: UITableView!
    
    /// 즐겨찾기 목록을 이 화면에서 사용하기 위한 배열
    private var places: [FavoritePlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    /// 즐겨찾기 탭으로 들어올 때마다 최신 데이터로 갱신
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FavoriteStore에 쌓여 있는 즐겨찾기 목록 가져오기
        places = FavoriteStore.shared.places
        tableView.reloadData()
    }
}


