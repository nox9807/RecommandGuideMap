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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = makeHorizontalPagerLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
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

extension ThemeDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        theme.locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LocationCardCell.reuseID,
            for: indexPath
        ) as! LocationCardCell
        
        let location = theme.locations[indexPath.item]
        cell.configure(location: location)
        
        // ⭐️ Delegate 연결 필수!
        cell.delegate = self
        
        return cell
    }
}

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
        let location = theme.locations[indexPath.item]
        openOnMap(place: location)
    }
}

private extension ThemeDetailViewController {
    func openOnMap(place: Location) {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            return
        }
        
        // TODO: 필요하다면 MapViewController에 선택된 장소 전달 기능 추가
        navigationController?.pushViewController(viewController, animated: true)
    }
}
