# BrandNew
2025 Junction Asia

> This README is provided in **English** and **Korean**.  
> 영어와 한국어 버전이 모두 제공됩니다.

---

# Soop Soo Ho
**Integrated Wildfire Risk Prediction and Spread Simulation Platform**  

---

## 🔥 Project Overview
This project is designed to address **wildfire issues in Gyeongsangbuk-do**,  
providing an **integrated solution for both prevention and response**.  

- **Prevention**: 3-Layer Risk Model incorporating human activity, forest characteristics, and soil data  
- **Response**: 4-Layer Simulation including zombie fires  

The platform goes beyond simple risk prediction, allowing users to **anticipate wildfire spread direction and speed once a fire occurs**.  

---

## 🧩 System Architecture

### 1. 3-Layer Risk Model (Prevention)
- **Layer 1. National Standard Wildfire Risk Index**
  - Implements the current national wildfire risk index (KFS)  
  - Ensures baseline model reliability
- **Layer 2. Human Activity Factor**
  - Approximately 70% of wildfires in South Korea are caused by human negligence  
  - Incorporates hiker statistics and data on residents near forest areas
- **Layer 3. Forest Characteristics + NDWI**
  - Gyeongsangbuk-do has a high proportion of coniferous trees, which burn longer than deciduous trees, increasing wildfire spread risk  
  - Uses **NDWI (Normalized Difference Water Index)** from satellite imagery
    - Higher NDWI → high moisture, lower risk  
    - Lower NDWI → dry vegetation, higher risk  

### 2. 4-Layer Simulation (Response)
- **Layer 4. Zombie Fire Factor**
  - Represents fires that re-ignite from underground embers  
  - Uses **ZFRI (Zombie Fire Risk Index)** integrating soil dryness, organic content, and recent fire history

---

## ☁️ Technology Stack
- **Azure Machine Learning**: Learns and optimizes the weight of each layer  
- **Google Maps + Sentinel Hub EO Browser**: Satellite imagery (NDWI) analysis and visualization  
- **SwiftUI**: User interface and simulation display  

---

## 📊 Key Features
- **Home View (Prevention Stage)**  
  - Provides risk heatmaps  
  - Lists Top 5 high-risk wildfire areas in Gyeongsangbuk-do  

- **Detail View (Response Stage)**  
  - Displays wildfire spread simulation for selected areas  
  - Provides zombie fire risk scores  

---

## 🚀 Expected Impact
- **Accurate Risk Prediction**: Overcomes limitations of weather-data-only models  
- **Region-Specific Response**: Considers human activity, forest composition, and soil characteristics  
- **Real-Time Decision Support**: Predicts wildfire spread direction and speed to improve firefighting efficiency  

---

## 👥 Team
- **Project Name**: Soop Soo Ho  
- **Track**: Azure-based Wildfire Response Solution (Gyeongsangbuk-do X POSTECH X Microsoft)  

---

# Soop Soo Ho
**산불 위험도 예측과 확산 시뮬레이션을 통합한 산불 대응 솔루션**  

---

## 🔥 프로젝트 개요
본 프로젝트는 **경상북도의 산불 문제**를 해결하기 위해 설계된 플랫폼으로,  
사전 예방과 사후 대응을 모두 아우르는 **통합 솔루션**입니다.  

- **사전 예방**: 사람·산림·토양 데이터를 반영한 **3-Layer 위험도 모델**  
- **사후 대응**: 좀비불까지 고려한 **4-Layer 시뮬레이션**  

이를 통해 단순한 위험 예측을 넘어, **산불이 실제로 발생했을 때 확산 경로와 속도까지 예측**할 수 있습니다.  

---

## 🧩 시스템 구조

### 1. 3-Layer 위험도 모델 (사전 예방)
- **Layer 1. 국가 기준 산불위험지수**
  - 현행 국가 산불위험지수(KFS 지표)를 그대로 구현  
  - 모델 신뢰성 확보
- **Layer 2. 사람 활동 요인**
  - 우리나라 산불의 약 70%가 사람 부주의로 발생  
  - 등산객 통계, 산림 인접 거주민 데이터 반영
- **Layer 3. 산림 특성 + NDWI**
  - 경상북도: 침엽수 비중이 활엽수보다 압도적으로 높아 산불 확산 위험이 큼  
  - 위성지표 **NDWI (Normalized Difference Water Index)** 활용  
    - NDWI ↑ → 수분 많음, 위험 낮음  
    - NDWI ↓ → 건조, 위험 높음  

### 2. 4-Layer 시뮬레이션 (사후 대응)
- **Layer 4. 좀비불 반영**
  - 지하 토양 속 불씨가 다시 발화하는 현상  
  - ZFRI (Zombie Fire Risk Index) 설계  
    - 토양 건조도, 유기물 함량, 최근 화재 이력 기반  

---

## ☁️ 기술 스택
- **Azure Machine Learning**: 각 레이어별 가중치 학습 및 최적화  
- **Google Map + Sentinel Hub EO Browser**: 위성 영상(NDWI) 분석 및 시각화  
- **SwiftUI**: 사용자 인터페이스 및 시뮬레이션 제공  

---

## 📊 주요 기능
- **홈뷰 (예방 단계)**  
  - 위험도 히트맵 제공  
  - 경상북도 산불 위험 지역 Top5 리스트  

- **상세뷰 (대응 단계)**  
  - 특정 지역 선택 시, 산불 발생 후 확산 경로 시뮬레이션  
  - 좀비불 발생 가능 수치 제공  

---

## 🚀 기대효과
- **정확한 위험 예측**: 기존 기상 데이터 중심 지표의 한계 보완  
- **지역 특화 대응**: 사람 활동, 산림 구성, 토양 특성을 반영  
- **실시간 의사결정 지원**: 산불 확산 방향과 속도를 예측하여 진압 효율성 향상  

---

## 👥 팀 소개
- **프로젝트명**: Soop Soo Ho  
- **참여 트랙**: Azure 기반 산불 대응 솔루션 (경상북도 X POSTECH X Microsoft)  

