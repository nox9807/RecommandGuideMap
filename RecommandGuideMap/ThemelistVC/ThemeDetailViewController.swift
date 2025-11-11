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
    
//    static func instantiate(theme: Theme) -> ThemeDetailViewController {
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "ThemeDetailViewController") as! ThemeDetailViewController
//        vc.theme = theme
//        return vc
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidesBottomBarWhenPushed = true
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        let ap = UINavigationBarAppearance()
        ap.configureWithTransparentBackground()
        ap.backgroundColor = .clear
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        title = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = makeHorizontalPagerLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        // 사진을 화면 끝까지: 세로 조정 없음
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = false
        
        print("registered identifiers?", collectionView.value(forKey: "_cellClassDict") ?? "n/a")
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
        section.contentInsets = .zero
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ThemeDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { theme.locations.count }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: LocationCardCell.reuseID, for: indexPath) as! LocationCardCell
        let locationAt = theme.locations[indexPath.item]
        cell.configure(location: locationAt)
        cell.onMap = { [weak self] p in self?.openOnMap(place: p) }
        return cell
    }
}

// MARK: - 지도 이동
private extension ThemeDetailViewController {
    func openOnMap(place: Location) {
        let vc = LocationMapViewController()
        vc.location = place
        navigationController?.pushViewController(vc, animated: true)
    }
}
