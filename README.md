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
| <img width="375" height="812" src="https://github.com/user-attachments/assets/5258732a-d7c9-4120-af80-126afb9ee8b0" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/4674e202-a7d8-4d03-a892-f8a3fa678395" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/f5699e6c-f6ac-4185-9b39-952db4433987"  /> |

### ✔ 홈 주요 기능
- 현재 위치 기반 근처 인기 장소 추천  
- 장소 선택 시 상세정보 제공  
- 길찾기 버튼 클릭 시 경로 탐색  
- 간단한 UI로 누구나 빠르게 길 찾기 가능  

---

## 🗺️ 테마지도(Theme Map)

| 테마지도 화면 | 테마 상세 화면 |
|----------------|----------------|
| <img width="375" height="812" src="https://github.com/user-attachments/assets/46cf3ecd-8e44-4ea7-b8ce-9073bd455886" /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/58e9a78d-1ec5-4796-873a-b27be118734f" /> |

### ✔ 테마지도 주요 기능
- 카테고리(데이트/카페/혼밥 등)별 지도 필터링  
- 테마 선택 시 해당 장소들만 지도에 표시  
- 심플한 지도 인터랙션  

---

## ⭐ 즐겨찾기(Favorites)


| 즐겨찾기 목록 | 루트 화면 | 루트 상세 화면 |
|---------------|-----------|----------------|
| <img width="375" height="812" src="https://github.com/user-attachments/assets/06a9fdb0-d029-4c0d-97ac-60dd0973b90e"  /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/54927646-1a9b-4c95-9705-d7c25dc0b893"  /> | <img width="375" height="812" src="https://github.com/user-attachments/assets/a9674920-feb2-48da-83d8-ffc274be9e22"  /> |

### ✔ 즐겨찾기 주요 기능
- 장소를 즐겨찾기하면 자동으로 목록에 저장  
- 저장된 장소 기반 루트 자동 생성  
- 루트 상세 화면에서 거리·소요시간·경로 확인  

---

# 🛠 구현 기술 및 라이브러리

**UI & Layout**  
- UIKit & Storyboard 기반 화면 구성  
- AutoLayout을 활용한 인터페이스 레이아웃  
- MapView, ThemeList, Favorite 모듈 단위로 화면 분리  

**Data Persistence**  
- CoreData를 활용한 장소 및 루트 정보 저장  
- FavoriteEntity 기반 CRUD 처리  
- 앱 실행 시 persistentContainer로 데이터 로드

**Concurrency**  
- async/await를 활용한 비동기 네트워킹 처리  
- URLSession 기반 API 요청  
- Codable 기반 JSON 파싱

**APIs**  
- **Naver Directions API**: 출발/도착지를 이용한 길찾기 경로 탐색  
- **TourAPI (한국관광공사)**: 테마별 장소/관광지/맛집 데이터 조회  

**Maps**  
- **NMapsMap (네이버 지도 SDK)**: 지도 렌더링, 마커 표시, 카메라 컨트롤  
- **NMapsGeometry**: 위·경도 및 경로 계산 보조

**Location**  
- **CoreLocation**: 사용자 현재 위치 추적 및 지도 초기 위치 설정  
- 위치 권한 요청 및 위치 업데이트 처리

**Architecture**  
- MVC 구조 기반  
- Favorite / MapView / ThemeList 모듈화  
- Model, Network, UI 레이어 구분 설계

**Dependencies**  
- NMapsMap 3.23.0  
- NMapsGeometry 1.0.2


---

## ⚙ 프로젝트 세팅

이 프로젝트는 **Naver Maps SDK**와 **TourAPI(공공데이터)** 를 사용합니다.  
원활한 실행을 위해 각 서비스에서 발급받은 API Key를 프로젝트에 설정해야 합니다.

---

### 1. 🔐 API Key 설정

#### 1) Secrets.xcconfig 파일 설정
다음 경로에 위치한 `Secrets.xcconfig` 파일에 API 키를 추가합니다.

`RecommandGuideMap/Secrets/Secrets.xcconfig`

```xcconfig
NAVER_CLIENT_ID = "네이버 지도 Client ID"
NAVER_CLIENT_SECRET = "네이버 지도 Client Secret"

NAVER_DIRECTION_CLIENT_ID = "네이버 길찾기 Client ID"
NAVER_DIRECTION_CLIENT_SECRET = "네이버 길찾기 Client Secret"

TOUR_SERVICE_KEY = "TourAPI 서비스 키"


# 📁 폴더 구조

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
