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
        
        return cell
    }
}

private extension ThemeDetailViewController {

    func openOnMap(place: Location) {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
