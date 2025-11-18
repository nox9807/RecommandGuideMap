# My Route  
> **내 일상의 길을 더 쉽게, My Route**

---

## 📱 앱 미리보기 (대표 이미지)
<div>
  
<img width="300" alt="iMockup - iPhone 15 Pro Max" src="https://github.com/user-attachments/assets/d87b6fe2-4c00-494b-bdab-f8a3f6a40bf9" />

</div>

---

## 🌟 간단한 소개
My Route는 **원하는 장소를 빠르게 찾고**,  
**테마별 인기 장소를 탐색하며**,  
**개인 루트를 저장하고 관리**할 수 있는 간편 지도 기반 길찾기 서비스입니다.

---

# 📌 주요 기능
- **홈** : 주변 추천 장소 탐색 및 길찾기
- **테마지도** : 카테고리(카페·데이트·핫플 등) 기반 장소 추천
- **즐겨찾기** : 내가 저장한 루트/장소 조회 및 루트 상세 확인

---

# 📸 앱 미리보기

---

## 🏠 홈(Home)

| 홈 화면 | 장소 상세 화면 | 길찾기 화면 |
|---------|----------------|--------------|
| <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> |

### ✔ 홈 주요 기능
- 현재 위치 기반 근처 인기 장소 추천  
- 장소 선택 시 상세정보 제공  
- 길찾기 버튼 클릭 시 경로 탐색  
- 간단한 UI로 누구나 빠르게 길 찾기 가능  

---

## 🗺️ 테마지도(Theme Map)

| 테마지도 화면 | 테마 상세 화면 |
|----------------|----------------|
| <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> |

### ✔ 테마지도 주요 기능
- 카테고리(데이트/카페/혼밥 등)별 지도 필터링  
- 테마 선택 시 해당 장소들만 지도에 표시  
- 심플한 지도 인터랙션  

---

## ⭐ 즐겨찾기(Favorites)

| 즐겨찾기 목록 | 루트 화면 | 루트 상세 화면 |
|---------------|-----------|----------------|
| <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/7933e73e-4e94-407a-977b-8ab87d0093f4" /> |

### ✔ 즐겨찾기 주요 기능
- 장소를 즐겨찾기하면 자동으로 목록에 저장  
- 저장된 장소 기반 루트 자동 생성  
- 루트 상세 화면에서 거리·소요시간·경로 확인  

---

# 🛠 구현 기술 및 라이브러리
(작성 예정)

---

# ⚙ 프로젝트 세팅
(작성 예정)

---

# 📁 폴더 구조
```
📁 RecommandGuideMap
├ 📁 Favorite                      
│   └ 📁 Model
│   │   ├ 📝 FavoriteModalViewController
│   │   ├ 📝 Place
│   │   ├ 📝 RouteDummyData
│   │   ├ 📝 RouteModel
│   ├ 📝 BaseMapViewController
│   ├ 📝 BottomSheetViewController 
│   ├ 📝 FavoriteMapViewController
│   ├ 📝 FavoriteStore
│   ├  FavoriteModel // 코어데이터
│   ├ 📝 PlaceCell
│   ├ 📝 PlaceViewController
│   ├ 📝 RouteCell
│   ├ 📝 RouteDetailViewController
│   ├ 📝 RouteViewController
├ 📁 MapView
│   └ 📁 Model
│   │   ├ 📝 ConvertDoubble
│   │   ├ 📝 SearchData
│   │   ├ 📝 SearchModel
│   └ 📁 UI
│   │   ├ 📝 DirectionsViewController
│   │   ├ 📝 InfoViewController
│   │   ├ 📝 MapViewController
│   │   ├ 📝 SearchViewController
├ 📁 ThemeList
│   └ 📁 DataModel
│   │   ├ 📝 BunbleDecoder
│   │   ├ 📝 ImageLoader
│   │   ├ 📝 Model
│   └ 📁 NetWork
│   │   ├ 📝 LocalThemeDTO
│   │   ├ 📝 TourAPI
│   └ 📁 resource
│   │   ├ blueRibbon
│   │   ├ hotelSeoul
│   │   ├ michelin
│   │   ├ michelinBib
│   │   ├ tourSpot
│   │   ├ yongsanCourse
│   └ 📁 UI
│   │   ├ 📝 LocationCardCell
│   │   ├ 📝 ThemeCardCell
│   │   ├ 📝 ThemeDetailViewController
│   │   ├ 📝 ThemeListViewController
```

---

# 👩‍💻 개발자 소개
최재영
이찬희
박채윤
