//
//  ThemeDetailViewController.swift
//  RecommandGuideMap
//

import UIKit

final class ThemeDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = makeHorizontalPagerLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = false
        
        title = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(visible: true)
        hidesBottomBarWhenPushed = true
    }
    
    private func configureNavigationBar(visible: Bool) {
        navigationController?.setNavigationBarHidden(!visible, animated: false)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance    = appearance
        navigationController?.navigationBar.tintColor            = .white
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func makeHorizontalPagerLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(1.0))
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(1.0)),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - CollectionView DataSource

extension ThemeDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        theme.locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LocationCardCell.reuseID,
            for: indexPath
        ) as! LocationCardCell
        
        let location = theme.locations[indexPath.item]
        cell.configure(location: location)
        cell.delegate = self      // ⭐ 반드시 연결
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let location = theme.locations[indexPath.item]
        openOnMap(place: location)
    } 
}

// MARK: - LocationCardCellDelegate

extension ThemeDetailViewController: LocationCardCellDelegate {
    
    // ⭐ 즐겨찾기 버튼 눌림
    func locationCardCellDidTapFavorite(_ cell: LocationCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let location = theme.locations[indexPath.item]
        FavoriteStore.shared.add(from: location)
        
        let alert = UIAlertController(
            title: "즐겨찾기 추가",
            message: "\"\(location.name)\"을(를) 즐겨찾기에 저장했습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // 🗺 지도 버튼 눌림
    func locationCardCellDidTapMap(_ cell: LocationCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let place = theme.locations[indexPath.item]
        openOnMap(place: place)
    }
}

private extension ThemeDetailViewController {
    func openOnMap(place: Location) {
        guard let location = theme.locations.first else { return }
        
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        guard let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            print("MapViewController not found")
            return
        }
        
        // SearchResponse.SearchItem 형식으로 변환 (MapViewController가 사용하는 구조)
        let item = SearchResponse.SearchItem(
            title: location.name,
            category: "추천 관광지",
            address: location.address,
            roadAddress: location.address,
            mapx: "(location.lng)",
            mapy: "(location.lat)"
        )
        
        mapVC.selectedItem = item
        mapVC.modalPresentationStyle = .fullScreen
        mapVC.isHiddenViews = true
        present(mapVC, animated: true)
    }
}

