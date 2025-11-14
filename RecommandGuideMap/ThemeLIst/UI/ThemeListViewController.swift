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
    
    enum FoodCategory: String, CaseIterable {
        case korean = "A05020100"
        case japanese = "A05020300"
        case chinese = "A05020400"
        
        var title: String {
            switch self {
                case .korean: return "한식"
                case .japanese: return "일식"
                case .chinese: return "중식"
            }
        }
    }
    
    // Provide (title, code) pairs derived from FoodCategory
    private var categories: [(title: String, code: String)] {
        FoodCategory.allCases.map { ($0.title, $0.rawValue) }
    }
    
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
    
    // ✅ 수정: String 반환
    private func coverURL(for firstImage: String?, fallbackSeed title: String) -> String {
        if let string = firstImage, !string.isEmpty {
            return string
        }
        
        let seed = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "cover"
        return "https://picsum.photos/seed/\(seed)/1200/800"
    }
    
    private func loadCategoryThemes() async {
        do {
            var newThemes: [Theme] = []
            
            do {
                // 1) 미쉐린 스타
                let michelinDTO: ThemeDTO = try Bundle.main.decode(ThemeDTO.self, file: "michelin")
                newThemes.append(michelinDTO.toTheme())
                
                // 2) 미쉐린 빕구르망
                let bibDTO: ThemeDTO = try Bundle.main.decode(ThemeDTO.self, file: "michelinBib")
                newThemes.append(bibDTO.toTheme())
                
                // 3) 블루리본 서베이
                let blueDTO: ThemeDTO = try Bundle.main.decode(ThemeDTO.self, file: "blueRibbon")
                newThemes.append(blueDTO.toTheme())
                
                // 4) 용산 데이트 코스
                let yongsanDTO: ThemeDTO = try Bundle.main.decode(ThemeDTO.self, file: "yongsanCourse")
                newThemes.append(yongsanDTO.toTheme())
                
            } catch {
                print("⚠️ Local JSON decode error:", error)
            }
            
            // API 테마 추가
            for (title, code) in categories {
                let locations: [Location] = try await TourAPIService.shared.searchKeyword(
                    title,
                    rows: 10,
                    page: 1
                )
                
                // ✅ 수정: imageURL 사용
                let cover = coverURL(
                    for: locations.first?.imageURL,
                    fallbackSeed: title
                )
                
                // ✅ 수정: coverImage, viewCount 제거
                newThemes.append(
                    Theme(
                        id: code,
                        title: "\(title) 맛집 ",
                        coverURL: cover,
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
