import numpy as np
import pandas as pd
from datetime import datetime
import random

class FireRiskCalculator:
    """
    3-Layer 산불위험지수 계산기
    Layer 1: 국가 기준 산불위험지수 (KFS)
    Layer 2: 사람 활동 요인
    Layer 3: 산림 특성 + NDWI
    """
    
    def __init__(self):
        # 각 레이어별 가중치 (Azure ML로 최적화된 값이라고 가정)
        self.layer_weights = {
            'kfs_index': 0.4,      # Layer 1 가중치
            'human_activity': 0.3,  # Layer 2 가중치
            'forest_ndwi': 0.3     # Layer 3 가중치
        }
    
    def calculate_kfs_index(self, temperature, humidity, wind_speed, precipitation):
        """
        Layer 1: 국가 기준 산불위험지수 계산
        """
        # 실효습도 계산 (간소화된 공식)
        effective_humidity = humidity * (1 - 0.01 * temperature)
        
        # 풍속 보정
        wind_factor = min(wind_speed / 10.0, 2.0)  # 최대 2배까지
        
        # 강수량 보정 (최근 7일간 누적 강수량 고려)
        rain_factor = max(0.1, 1 - precipitation / 50.0)
        
        # KFS 지수 계산 (0-100 스케일)
        kfs_score = (100 - effective_humidity) * wind_factor * rain_factor
        return min(max(kfs_score, 0), 100)
    
    def calculate_human_activity_risk(self, population_density, hiking_trails, 
                                    residential_proximity, day_of_week):
        """
        Layer 2: 사람 활동 요인 계산
        """
        # 인구밀도 점수 (명/km²)
        pop_score = min(population_density / 1000.0 * 30, 30)
        
        # 등산로 밀도 점수
        trail_score = hiking_trails * 15  # 등산로 개수당 15점
        
        # 주거지 근접성 점수 (km 단위, 가까울수록 위험)
        proximity_score = max(0, 25 - residential_proximity * 5)
        
        # 요일별 가중치 (주말이 더 위험)
        weekend_multiplier = 1.5 if day_of_week in [5, 6] else 1.0  # 토, 일
        
        human_risk = (pop_score + trail_score + proximity_score) * weekend_multiplier
        return min(human_risk, 100)
    
    def calculate_forest_ndwi_risk(self, conifer_ratio, ndwi_value, slope, elevation):
        """
        Layer 3: 산림 특성 + NDWI 계산
        """
        # 침엽수 비율 점수 (경상북도 특성 반영)
        conifer_score = conifer_ratio * 40  # 침엽수 비율이 높을수록 위험
        
        # NDWI 점수 계산
        # NDWI 범위: -1 ~ 1 (높을수록 수분 많음, 낮을수록 건조)
        # 위험도는 NDWI가 낮을수록 높음
        ndwi_risk = (1 - ndwi_value) * 30  # -1~1을 0~60 범위로 변환
        ndwi_score = max(0, min(ndwi_risk, 60))
        
        # 경사도 점수 (급경사일수록 확산 위험 증가)
        slope_score = min(slope / 45.0 * 20, 20)  # 45도 기준으로 정규화
        
        # 고도 점수 (고도가 높을수록 건조, 바람 영향 증가)
        elevation_score = min(elevation / 1000.0 * 10, 15)
        
        forest_risk = conifer_score + ndwi_score + slope_score + elevation_score
        return min(forest_risk, 100)
    
    def calculate_integrated_risk(self, weather_data, human_data, forest_data):
        """
        통합 산불위험지수 계산
        """
        # Layer 1: KFS 지수
        kfs_risk = self.calculate_kfs_index(
            weather_data['temperature'],
            weather_data['humidity'],
            weather_data['wind_speed'],
            weather_data['precipitation']
        )
        
        # Layer 2: 사람 활동 위험도
        human_risk = self.calculate_human_activity_risk(
            human_data['population_density'],
            human_data['hiking_trails'],
            human_data['residential_proximity'],
            human_data['day_of_week']
        )
        
        # Layer 3: 산림 + NDWI 위험도
        forest_risk = self.calculate_forest_ndwi_risk(
            forest_data['conifer_ratio'],
            forest_data['ndwi_value'],
            forest_data['slope'],
            forest_data['elevation']
        )
        
        # 가중 평균으로 최종 위험도 계산
        total_risk = (
            kfs_risk * self.layer_weights['kfs_index'] +
            human_risk * self.layer_weights['human_activity'] +
            forest_risk * self.layer_weights['forest_ndwi']
        )
        
        return {
            'total_risk': round(total_risk, 2),
            'kfs_risk': round(kfs_risk, 2),
            'human_risk': round(human_risk, 2),
            'forest_risk': round(forest_risk, 2),
            'risk_level': self.get_risk_level(total_risk)
        }
    
    def get_risk_level(self, risk_score):
        """위험도 등급 분류"""
        if risk_score >= 80:
            return "매우 높음"
        elif risk_score >= 60:
            return "높음"
        elif risk_score >= 40:
            return "보통"
        elif risk_score >= 20:
            return "낮음"
        else:
            return "매우 낮음"

# 사용 예시
def generate_sample_data():
    """경상북도 지역별 샘플 데이터 생성"""
    regions = ["안동시", "경주시", "포항시", "구미시", "영주시"]
    
    sample_data = []
    
    for region in regions:
        # 기상 데이터 (임의 생성)
        weather_data = {
            'temperature': random.uniform(15, 35),  # 온도 (°C)
            'humidity': random.uniform(30, 80),     # 습도 (%)
            'wind_speed': random.uniform(2, 15),    # 풍속 (m/s)
            'precipitation': random.uniform(0, 20)   # 강수량 (mm)
        }
        
        # 사람 활동 데이터
        human_data = {
            'population_density': random.uniform(100, 2000),  # 인구밀도 (명/km²)
            'hiking_trails': random.randint(1, 8),            # 등산로 개수
            'residential_proximity': random.uniform(0.5, 10), # 주거지 거리 (km)
            'day_of_week': random.randint(0, 6)               # 요일 (0=월, 6=일)
        }
        
        # 산림 + NDWI 데이터
        forest_data = {
            'conifer_ratio': random.uniform(0.6, 0.9),    # 침엽수 비율 (경북 특성)
            'ndwi_value': random.uniform(-0.3, 0.4),      # NDWI 지수
            'slope': random.uniform(10, 40),              # 경사도 (도)
            'elevation': random.uniform(200, 1200)        # 고도 (m)
        }
        
        sample_data.append({
            'region': region,
            'weather': weather_data,
            'human': human_data,
            'forest': forest_data
        })
    
    return sample_data

# 실행 예시
if __name__ == "__main__":
    calculator = FireRiskCalculator()
    sample_data = generate_sample_data()
    
    print("=== 경상북도 산불위험지수 계산 결과 ===\n")
    
    results = []
    for data in sample_data:
        result = calculator.calculate_integrated_risk(
            data['weather'], 
            data['human'], 
            data['forest']
        )
        result['region'] = data['region']
        result['ndwi'] = round(data['forest']['ndwi_value'], 3)
        results.append(result)
    
    # 위험도 순으로 정렬
    results.sort(key=lambda x: x['total_risk'], reverse=True)
    
    print("📊 지역별 위험도 순위:")
    print("-" * 80)
    print(f"{'순위':<4} {'지역':<8} {'종합위험도':<10} {'NDWI':<8} {'위험등급':<10} {'KFS':<6} {'인간':<6} {'산림':<6}")
    print("-" * 80)
    
    for i, result in enumerate(results, 1):
        print(f"{i:<4} {result['region']:<8} {result['total_risk']:<10} "
              f"{result['ndwi']:<8} {result['risk_level']:<10} "
              f"{result['kfs_risk']:<6} {result['human_risk']:<6} {result['forest_risk']:<6}")
    
    print(f"\n🔥 최고 위험 지역: {results[0]['region']} (위험도: {results[0]['total_risk']})")
    print(f"💧 NDWI가 가장 낮은 지역: {min(results, key=lambda x: x['ndwi'])['region']} "
          f"(NDWI: {min(results, key=lambda x: x['ndwi'])['ndwi']})")
