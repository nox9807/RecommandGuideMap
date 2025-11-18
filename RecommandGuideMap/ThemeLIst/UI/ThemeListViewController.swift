/// [feat] 테마 리스트 화면 구현 및 데이터 로딩 파이프라인 구성
/// - 로컬 JSON(더미) + TourAPI 검색 결과를 합쳐서 Theme 배열 생성
/// - 콤포지셔널 레이아웃 기반 리스트 UI
/// - Theme 선택 시 ThemeDetailViewController로 네비게이션
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
    
    private let categories: [(title: String, code: String)] = [
        ("한식", "A05020100"),
        ("일식", "A05020300"),
        ("중식", "A05020400")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "테마지도"
        
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        Task { await loadThemes() }
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
    /// [feat] 테마 데이터 로딩
    /// - 1) 로컬 JSON 기반 Theme 로드
    /// - 2) TourAPI 카테고리별 검색 결과를 Theme로 변환
    private func loadThemes() async {
        do {
            var allThemes: [Theme] = []
            
            let localFiles = ["michelin", "michelinBib", "blueRibbon", "yongsanCourse", "hotelSeoul", "tourSpot"]
            for fileName in localFiles {
                do {
                    let themeDTO: ThemeDTO = try Bundle.main.decode(ThemeDTO.self, file: fileName)
                    allThemes.append(themeDTO.toTheme())
                } catch {
                    print("⚠️ \(fileName) 로드 실패: \(error)")
                }
            }
            
            for (title, code) in categories {
                do {
        
                    let locations = try await TourAPI.shared.search(keyword: title, rows: 10)
                    
                    let coverURL = locations.first?.imageURL ?? "https://picsum.photos/1200/800"
                    
                    allThemes.append(Theme(
                        id: code,
                        title: "\(title) 맛집",
                        coverURL: coverURL,
                        locations: locations
                    ))
                } catch {
                    print("⚠️ \(title) API 로드 실패: \(error)")
                }
            }
            
            // UI 업데이트
            await MainActor.run {
                self.themes = allThemes
                self.collectionView.reloadData()
            }
            
        } catch {
            await MainActor.run {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "불러오기 실패",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
