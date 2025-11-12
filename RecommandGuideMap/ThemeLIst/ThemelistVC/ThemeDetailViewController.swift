//
//  ThemeDetailViewController.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class ThemeDetailViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var theme: Theme!


    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 페이징 전용 레이아웃
        collectionView.collectionViewLayout = makeHorizontalPagerLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        // 사진을 화면 끝까지 보이도록
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = false
        
        // 제목은 카드 내에서 표현하므로 네비게이션 타이틀은 숨김
        title = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(visible: true)
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: - UI
    private func configureNavigationBar(visible: Bool) {
        navigationController?.setNavigationBarHidden(!visible, animated: false)
        
        let ap = UINavigationBarAppearance()
        ap.configureWithTransparentBackground()
        ap.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance   = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance    = ap
        navigationController?.navigationBar.tintColor            = .white
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func makeHorizontalPagerLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.contentInsets = .zero
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - CollectionView
extension ThemeDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theme.locations.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: LocationCardCell.reuseID,
            for: indexPath
        ) as! LocationCardCell
        
        let location = theme.locations[indexPath.item]
        cell.configure(location: location)
        
//        // 지도 버튼 액션
//        cell.onMap = { [weak self] place in
//            self?.openOnMap(place: place)
//        }
        return cell
    }
}

// MARK: - Navigation
private extension ThemeDetailViewController {
    /// 팀원 MapViewController 재사용: Storyboard("Map") / Identifier("MapViewController")
    func openOnMap(place: Location) {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            return
        }
//        vc.initialPin = (lat: place.lat, lng: place.lng, title: place.name)
        navigationController?.pushViewController(vc, animated: true)
    }
}
