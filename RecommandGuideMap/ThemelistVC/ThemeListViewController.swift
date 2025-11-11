//
//  ThemeListViewController.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class ThemeListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var themes: [Theme] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "테마지도"
        
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        loadThemes()
    }
    
    private func loadThemes() {
        themes = mockData()
        collectionView.reloadData()
    }
    
    // 더미 데이터 (에셋: "ksup", "lpBar")
    private func mockData() -> [Theme] {
        let place1 = Location(
            id: "p1", name: "콜트레인", rating: 4.5,
            distanceText: "7.5km · 서울 중구 충무로3가", address: "서울 중구 충무로3가",
            description: "LP와 재즈가 흐르는 감성 바",
            photo: UIImage(named: "ksup")!, lat: 37.561, lng: 126.986
        )
        let place2 = Location(
            id: "p2", name: "페이지스", rating: 4.3,
            distanceText: "3.2km · 서울 마포구", address: "서울 마포구",
            description: "잔잔한 대화하기 좋은 곳",
            photo: UIImage(named: "lpBar")!, lat: 37.549, lng: 126.914
        )
        
        let theme1 = Theme(
            id: "t1",
            title: "음악에 취해 한잔하기 좋은 뮤직바",
            coverURL: URL(string: "https://picsum.photos/seed/t1/1200/800")!,
            viewCount: 718,
            places: [place1, place2]
        )
        let theme2 = Theme(
            id: "t2",
            title: "여기가 한국이라고? 이국 감성 거리",
            coverURL: URL(string: "https://picsum.photos/seed/t2/1200/800")!,
            viewCount: 668,
            places: [place2, place1]
        )
        return [theme1, theme2]
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let item  = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(1.0))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .absolute(240)),
            subitems: [item]
        )
        group.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetailSegue",
              let dest = segue.destination as? ThemeDetailViewController else { return }
        
        if let cell = sender as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            dest.theme = themes[indexPath.item]
            dest.hidesBottomBarWhenPushed = true
            return
        }
        
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            dest.theme = themes[indexPath.item]
            dest.hidesBottomBarWhenPushed = true
        }
    }

    
}

extension ThemeListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { themes.count }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: ThemeCardCell.reuseID, for: indexPath) as! ThemeCardCell
        cell.configure(theme: themes[indexPath.item])
        return cell
    }
    
}

