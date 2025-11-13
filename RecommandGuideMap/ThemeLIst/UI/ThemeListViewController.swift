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
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(240)
            ),
            subitems: [item]
        )
        group.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func coverURL(for firstImage: String?, fallbackSeed title: String) -> URL? {
        if let string = firstImage,
           let url = URL(string: string),
           !string.isEmpty {
            return url
        }
        
        let seed = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "cover"
        return URL(string: "https://picsum.photos/seed/\(seed)/1200/800")
    }
    
    private func loadCategoryThemes() async {
        do {
            var newThemes: [Theme] = []
            
            // 1️⃣ 로컬 JSON 기반 테마들을 먼저 추가 (항상 리스트 최상단에 오게)
            do {
                // 1) 미쉐린 스타 레스토랑
                let michelinDTO: ThemeDTO = try Bundle.main.decode(
                    ThemeDTO.self,
                    file: "michelin"
                )
                let michelinTheme = michelinDTO.toTheme()
                newThemes.append(michelinTheme)
                
                // 2) 미쉐린 빕구르망 추가 🔥🔥
                let bibDTO: ThemeDTO = try Bundle.main.decode(
                    ThemeDTO.self,
                    file: "michelinBib"     // michelinBib.json
                )
                let bibTheme = bibDTO.toTheme()
                newThemes.append(bibTheme)
                
            } catch {
                print("⚠️ Local JSON decode error:", error)
            }
            
            // 2️⃣ TourAPI 기반 테마들을 아래쪽에 추가
            for (title, code) in categories {
                let locations: [Location] = try await TourAPIService.shared.searchKeyword(
                    title,
                    rows: 10,
                    page: 1
                )
                
                let cover = coverURL(
                    for: locations.first?.photoURL?.absoluteString,
                    fallbackSeed: title
                )
                
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
            
            // 3️⃣ 최종 UI 반영
            await MainActor.run {
                self.themes = newThemes
                self.collectionView.reloadData()
            }
        } catch {
            await MainActor.run {
                let message = (error as NSError).localizedDescription
                let alert = UIAlertController(
                    title: "불러오기 실패",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
            print("API error:", error)
        }
    }



    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetailSegue",
              let destination = segue.destination as? ThemeDetailViewController else { return }
        
        if let cell = sender as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            destination.theme = themes[indexPath.item]
            destination.hidesBottomBarWhenPushed = true
            return
        }
        
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            destination.theme = themes[indexPath.item]
            destination.hidesBottomBarWhenPushed = true
        }
    }
}

extension ThemeListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThemeCardCell.reuseID,
            for: indexPath
        ) as! ThemeCardCell
        
        cell.configure(theme: themes[indexPath.item])
        return cell
    }
}
