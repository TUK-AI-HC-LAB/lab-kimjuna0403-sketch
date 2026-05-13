# 세 모델 비교표 (PatchCore / SimpleNet / Reverse Distillation)

## 1. 학습 패러다임

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **핵심 방식** | 정상 피처 저장 후 kNN 비교 | 가짜 불량 생성 → Discriminator 학습 | Teacher(Enc)↔Student(Dec) 코사인 유사도 |
| **학습 필요 여부** | ❌ (피처 저장만) | ✅ (Feature Adapter + Discriminator) | ✅ (OCBE + Student Decoder) |
| **불량 샘플 필요 여부** | ❌ | ❌ (Gaussian noise로 생성) | ❌ (Bottleneck으로 차단) |
| **도메인 적응** | ❌ (ImageNet 피처 그대로) | ✅ (Feature Adapter로 산업 도메인 변환) | △ (OCBE가 정상 패턴에 특화되도록 학습) |
| **backbone** | WideResNet50, layer2+3 | WideResNet50, layer2+3 | WideResNet50, layer1+2+3 |

---

## 2. Anomaly Score 산출 방식

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **score 산출** | 테스트 피처 ↔ 메모리뱅크 kNN 거리 | Discriminator 출력값 (정상=높음, 불량=낮음) | Teacher vs Student 피처 코사인 유사도 (낮을수록 이상) |
| **이미지 단위 score** | 패치 중 최댓값 | anomaly map 최댓값 | anomaly map 최댓값 |
| **픽셀 단위 localization** | 패치별 kNN 거리 → 업샘플 | 위치별 Discriminator 출력 → 업샘플 | 멀티스케일 유사도 맵 합산 → 업샘플 |
| **스케일 수** | 2 (layer2+3) | 2 (layer2+3) | 3 (layer1+2+3) |

---

## 3. 학습 시간 / 추론 속도

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **학습 시간** | 없음 (수 분) | epoch당 ~1분 30초 (160 epoch = 약 6시간) | epoch당 유사 (200 epoch = 수 시간) |
| **추론 속도 (논문)** | ~6 FPS | **77 FPS** | 0.31s/img |
| **추론 속도 느린 이유** | 메모리뱅크 kNN 검색 | - | - |
| **실험 환경** | Colab T4 (수 분) | Colab T4 (6시간) | Kaggle T4 (GPU 한도 소진으로 전환) |

---

## 4. 메모리 사용량

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **메모리 구조** | 메모리뱅크 (정상 피처 저장) | 모델 파라미터만 | 모델 파라미터만 |
| **메모리 사용량** | 이미지 수에 비례해서 증가 | 중간 | **352MB (가장 작음)** |
| **coreset subsampling** | ✅ (10%로 압축 가능) | ❌ | ❌ |
| **확장성** | 데이터 많아질수록 불리 | 고정 | 고정 |

---

## 5. 카테고리별 안정성 (본인 실험 기준)

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **hazelnut** | I-AUROC 1.000 / P-AUROC 0.987 | I-AUROC 1.000 / P-AUROC 0.978 (epoch 40) | I-AUROC 1.000 / P-AUROC 0.989 (epoch 200) |
| **bottle** | I-AUROC 1.000 / P-AUROC 0.985 | I-AUROC 확인 (epoch 1) | 미실험 |
| **screw** | I-AUROC 0.988 / P-AUROC 0.995 | I-AUROC 0.895 / P-AUROC 0.977 (epoch 160, 수렴 불안정) | 미실험 |
| **안정성 평가** | ✅ 카테고리 무관하게 안정적 | ⚠️ 미세 결함 카테고리에서 불안정 | 확인 필요 (hazelnut만 실험) |

---

## 6. 종합 평가

| | PatchCore | SimpleNet | Reverse Distillation |
|---|---|---|---|
| **강점** | 학습 불필요, 안정적 성능 | 빠른 추론, 도메인 적응 | 메모리 효율, 빠른 추론 |
| **약점** | 느린 추론, 메모리 증가 | 미세 결함 카테고리 불안정, 학습 시간 김 | 구현 복잡, 카테고리 검증 부족 |
| **적합한 환경** | 안정성 중요한 환경 | 실시간 추론 필요한 환경 | 메모리 제약 환경 |

---

## 출처

- commit: `f6c79f0`
- 관련 파일:
  - method1_patchcore/markdown/Towards Total Recall in Industrial Anomaly Detection - 산업용 이상 탐지에 있어서의 완전한 재현율을 향하여.md
  - method2_simplenet/markdown/SimpleNet, A Simple Network for Image Anomaly Detection and Localization - 이미지 이상 탐지 및 위치 특정(국지화)을 위한 단순 신경망.md
  - method2_simplene/markdown/추가_SimpleNet epoch 160으로 돌려보기.md
  - method3_rd/markdown/Anomaly Detection via Reverse Distillation from One-Class Embedding-단일 클래스 임베딩으로부터의 역증류를 통한 이상 탐지.md
