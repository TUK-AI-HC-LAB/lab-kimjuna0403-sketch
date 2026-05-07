# Weekly Log

## 2026-W19 
- 미팅 자료: [meetings/2026-W19_brief.md](meetings/2026-W19_brief.md)

### 전주 계획 달성도
- [x] SimpleNet screw epoch=160 실험 → I-AUROC 0.895 (`method2_simplenet/source/results/screw160_results.csv`)
- [x] Reverse Distillation hazelnut epoch=200 실험 → I-AUROC 1.000 (`method3_rd/source/results/rd_hazelnut_20260507.csv`)
- [x] 아키텍처 다이어그램 생성 (Claude AI 활용, 각 method source에 첨부)
- [x] RD 논문 요약 → `method3_rd/markdown/SimpleNet, A Simple Network for Image Anomaly Detection and Localization - 이미지 이상 탐지 및 위치 특정(국지화)을 위한 단순 신경망.md`

### 이전 미팅 결정 사항
- SimpleNet epoch=160으로 재실험 (논문 기본값 맞추기)
- Colab GPU 한도 파악
- 코드 아키텍처 공부
- RD 논문 요약 + 코드 구현

### 다음 미팅까지의 계획
- 세 모델 비교표 작성 (학습 패러다임 / score 산출 방식 / 학습 시간 / 메모리 / 카테고리 안정성 5축) → `method1_patchcore/markdown/comparison_table.md`
- 각 모델 한계 + 원인 가설 정리 → 각 method markdown 업데이트
- 후속 논문 조사 (DRAEM, EfficientAD, FastFlow, GLASS, RealNet 중 모델당 2~3편)
- method4 후보 1편 선정 + 사유 정리

---

## 2026-W18 

### 전주 계획 달성도
- [x] PatchCore/SimpleNet hazelnut 비교 실험 완료
  - PatchCore: I-AUROC 1.000 / full_pixel_auroc 0.987 
  - SimpleNet (epoch 40): I-AUROC 1.000 / full_pixel_auroc 0.978 
- [x] PatchCore/SimpleNet 논문 요약 + 비교 분석 완료 (`method2_simplenet/markdown/SimpleNet, A Simple Network for Image Anomaly Detection and Localization - 이미지 이상 탐지 및 위치 특정(국지화)을 위한 단순 신경망.md`)

### 이전 미팅 결정 사항
- SimpleNet epoch=160으로 재실험 (논문 기본값, Colab GPU 한도 파악 겸)
- 코드 아키텍처 공부
- RD(Reverse Distillation) 논문 요약 + 코드 구현

### 다음 미팅까지의 계획
- SimpleNet screw epoch=160 실험 → `method2_simplenet/source/markdown/추가_SimpleNet epoch 160으로 돌려보기.md`
- RD 논문 요약 → `method3_rd/markdown/Anomaly Detection via Reverse Distillation from One-Class Embedding-단일 클래스 임베딩으로부터의 역증류를 통한 이상 탐지.md`
- RD 코드 구현 → `method3_rd/source/run-rd-hazelnut.ipynb`

---

## 2026-W17 

### 전주 계획 달성도
- [x] PatchCore 논문 요약 → `method1_patchcore/markdown/Towards Total Recall in Industrial Anomaly Detection - 산업용 이상 탐지에 있어서의 완전한 재현율을 향하여.md`
- [x] PatchCore bottle 재현 → I-AUROC 1.000 / full_pixel_auroc 0.985 / anomaly_pixel_auroc 0.980

### 이전 미팅 결정 사항
- SimpleNet 논문 조사 + PatchCore와 비교 실험

### 다음 미팅까지의 계획
- SimpleNet 논문 요약
- PatchCore/SimpleNet hazelnut 비교 실험
