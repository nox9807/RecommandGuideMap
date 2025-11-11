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
            id: "p1", name: "바다회사랑", rating: 4.5,
            distanceText: "7.5km · 서울 마포구 동교로27길 60", address: "서울 마포구 동교로27길 60",
            description: "방어가 살아 숨쉬는 듯한 싱싱함. 겨울하면 생각나는 방어회 맛집",
            photo: UIImage(named: "searawfish")!, lat: 37.561, lng: 126.986
        )
        let place2 = Location(
            id: "p2", name: "우래옥", rating: 4.9,
            distanceText: "3.2km · 서울 중구 창경궁로 62-29", address: "서울 중구 창경궁로 62-29",
            description: "80년 전통의 대한민국 최고의 평양냉면집. 우래옥만의 담백한 감칠맛을 경험해보세요. ",
            photo: UIImage(named: "coldnoodle")!, lat: 37.549, lng: 126.914
        )
        let place3 = Location(
            id: "p3", name: "보물섬 논현", rating: 4.3,
            distanceText: "3.2km · 서울 강남구 테헤란로20길 11-1", address: "서울 강남구 테헤란로20길 11-1",
            description: "강남 골목안 보물섬처럼 자리하고 있는 방어 맛집",
            photo: UIImage(named: "island")!, lat: 37.549, lng: 126.914
        )
        let place4 = Location(
            id: "p4", name: "금돼지식당", rating: 4.3,
            distanceText: "3.2km · 서울 중구 다산로 149", address: "서울 중구 다산로 149",
            description: "슈퍼스타 베컴도 다녀간 맛집. 서울 최고의 돼지고기를 경험해보세요!",
            photo: UIImage(named: "goldpig")!, lat: 37.549, lng: 126.914
        )
        
        let theme1 = Theme(
            id: "t1",
            title: "겨울은 대방어의 계절! 서울 방어 맛집 모음",
            photo: UIImage(named: "bigfish")!,
            viewCount: 718,
            locations: [place1, place3]
        )
        let theme2 = Theme(
            id: "t2",
            title: "합리적인 가격대에 미쉐린이? ",
            photo: UIImage(named: "michelin")!,
            viewCount: 668,
            locations: [place2, place4]
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

