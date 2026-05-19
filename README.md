# TUK AI-HC Lab — 김준아 Repository

## 소개
산업용 이상 탐지(Anomaly Detection) 논문 학습 및 재현 실험 기록.
MVTec AD 벤치마크 기준으로 각 모델을 재현하고 비교 분석 중.

---

## 다루는 Method

| # | 폴더 | 논문 | 상태 |
|---|---|---|---|
| 1 | method1_patchcore | Roth et al., 2022, Towards Total Recall in Industrial Anomaly Detection (CVPR 2022, PatchCore) | ✅ 재현 완료 (MVTec AD: hazelnut, screw) |
| 2 | method2_simplenet | Liu et al., 2023, SimpleNet: A Simple Network for Image Anomaly Detection and Localization (CVPR 2023) | ✅ 재현 완료 (MVTec AD: hazelnut, screw) |
| 3 | method3_rd | Deng et al., 2022, Anomaly Detection via Reverse Distillation from One-Class Embedding (CVPR 2022) | ✅ 재현 완료 (MVTec AD: hazelnut) |
| 4 | method4_Dinomaly | Dinomaly: The Less Is More Philosophy in Multi-Class Unsupervised Anomaly Detection  | ✅ 재현 완료 (MVTec AD 15클래스 전체) |

---

진행 상황 요약
**2026-W21** (현재) —  Dinomaly 재현 완료 + 한계점 분석

MVTec-AD 15클래스 전체 재현: Mean I-AUROC 99.62% (논문 99.6% 오차 범위 내)
SimpleNet 한계 검증표 작성 → method4_dinomaly/markdown/simplenet_limit_verification.md
Dinomaly 한계점 분석 작성 → method4_dinomaly/markdown/Dinomaly_한계점_분석.md
→ meetings/2026-W21_brief.md

**2026-W20 (5/14 미팅)** — 세 모델 비교 분석 + 후속 논문 조사 완료.

세 모델 구조적 한계 및 수렴 실패 원인 가설 정리 → method1_patchcore/markdown/산업용 이상 탐지 모델의 카테고리 의존성에 관한 비교 연구.md
후속 논문 8편 한계 매핑 (FastFlow, EfficientAD, RealNet, DRAEM, DeSTSeg, SuperSimpleNet, RD++, ReContrast) → method1_patchcore/markdown/followup_papers.md
→ meetings/2026-W20_brief.md

**2026-W19 (5/7 미팅)** — PatchCore/SimpleNet/RD 세 모델 재현 완료.
- PatchCore screw: I-AUROC 0.988 / hazelnut: I-AUROC 1.000
- SimpleNet screw epoch 160: I-AUROC 0.895 (논문 대비 -8.7%p, 수렴 불안정)
- RD hazelnut epoch 200: I-AUROC 1.000 / P-AUROC 0.989
- → meetings/2026-W19_brief.md
---

## 빠른 링크

- [WEEKLY_LOG.md](WEEKLY_LOG.md)
- [meetings/](meetings/)
- [method1_patchcore/](method1_patchcore/)
- [method2_simplenet/](method2_simplenet/)
- [method3_rd/](method3_rd/)

