//
//  ThemeListViewController.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class ThemeListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var themes: [Theme] = []
    
    // 7개 카테고리
    private let categories: [(title: String, cat3: String)] = [
        ("한식", "A05020100"),
        ("일식", "A05020300"),
        ("중식", "A05020400")
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "테마지도"
        
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        Task { await loadCategoryThemes() }
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
    
    private func coverURL(for firstImage: String?, fallbackSeed title: String) -> URL? {
        if let s = firstImage, let u = URL(string: s), !s.isEmpty { return u }
        return URL(string: "https://picsum.photos/seed/\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "cover")/1200/800")
    }
    
    // MARK: - 데이터 로드 (SimpleTourAPI 사용)
    private func loadCategoryThemes() async {
        do {
            var newThemes: [Theme] = []
            
            for (title, code) in categories {
                // ✅ [Location]을 바로 받음 (DTO 접근 X)
                let locations: [Location] = try await SimpleTourAPI.searchKeyword(title, rows: 10, page: 1)
                
                let cover = coverURL(for: locations.first?.photoURL?.absoluteString, fallbackSeed: title)
                
                newThemes.append(
                    Theme(
                        id: code,
                        title: "\(title) 맛집 ",
                        coverImage: nil,
                        coverURL: cover,
                        viewCount: locations.count,
                        locations: locations
                    )
                )
            }
            
            await MainActor.run {
                self.themes = newThemes
                self.collectionView.reloadData()
            }
        } catch {
            await MainActor.run {
                let msg = (error as NSError).localizedDescription
                let alert = UIAlertController(title: "불러오기 실패", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
            print("API error:", error)
        }
    }
    
    // segue로 상세로 넘어가는 경우 기존 로직 유지
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

