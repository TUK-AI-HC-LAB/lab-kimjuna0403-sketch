# SimpleNet 한계 검증표 — Dinomaly가 해결하는가?

## 검증 기준
- SimpleNet 수치: 논문(Liu et al., CVPR 2023) 기준
- Dinomaly 수치: 재현 실험 기준 (MVTec-AD 15클래스, 10,000 iter, ViT-Base/14 DINOv2-R)
- 출처: `method4_dinomaly/source/results/dinomaly_mvtec_results.csv`

---

## 표 1. 구조적 한계 검증

| 한계 항목 | SimpleNet | Dinomaly | 해결 여부 | 근거 |
|---|---|---|---|---|
| **Synthetic anomaly 의존** | 고정 Gaussian noise (σ=0.015)로 가짜 불량 생성. σ값이 카테고리마다 최적이라는 보장 없음 (논문 Figure 5) | Dropout으로 noise 효과 대체. 외부 σ 지정 없음 | ✅ 구조적 해결 | Dinomaly 논문 Table A8: Dropout이 Feature Jitter 대비 하이퍼파라미터 변화에 더 강건 |
| **test=validation 혼용** | 논문에서 test set을 validation에 그대로 사용. 성능 수치의 과대 추정 가능성 | 복원 오류 기반 구조로 별도 validation 불필요. test set 혼용 구조 없음 | ✅ 구조적 해결 | 교수님 피드백 및 SimpleNet 논문 실험 설정 |
| **MUAD 미지원** | class-separated 설정만 지원. 클래스마다 모델을 따로 학습해야 함 | MUAD 설계 목표. 15클래스 단일 모델로 학습 | ✅ 해결 | Dinomaly 재현: 15클래스 동시 학습 I-AUROC 99.62% |
| **Discriminator 오버피팅** | Discriminator가 가짜 불량을 학습 초반에 완벽히 구분한 뒤, 이후 실제 결함 일반화 실패 가능 | Discriminator 구조 자체가 없음. 복원 오류를 직접 이상치 점수로 사용 | ✅ 구조적 해결 | Dinomaly는 Discriminator 미사용 |

---

## 표 2. 성능 수치 검증 (MVTec-AD 기준)

| 지표 | PatchCore (논문) | SimpleNet (논문) | Dinomaly (재현) | SimpleNet 대비 |
|---|---|---|---|---|
| **I-AUROC (전체 평균)** | 99.1% | 99.6% | **99.62%** | +0.02%p |
| **P-AUROC (전체 평균)** | 98.1% | 98.1% | **98.32%** | +0.22%p |
| **P-AUPRO (전체 평균)** | 93.5% | 90.0% | **94.65%** | +4.65%p ✅ |
| **screw I-AUROC** | 98.8% | 98.2% | **98.50%** | +0.3%p |
| **screw P-AUROC** | 99.4% | 99.3% | **99.64%** | +0.34%p |
| **transistor P-AUPRO** | - | - | 75.31% | ⚠️ 유독 낮음 |

---
⚠️ transistor P-AUPRO 75.31% — 유독 낮음
transistor처럼 결함이 작고 국소적인 카테고리에서 P-AUPRO가 낮다는 건, 이미지 수준 탐지는 잘 하는데 정확히 어디가 결함인지 픽셀 단위로 가리키는 건 부족하다는 의미이다. 정확한 원인은 논문에서 별도로 분석되지 않는다. 다만 transistor는 납땜 부위, 핀 휨 등 결함이 극히 국소적이고 이미지마다 부품 방향이 다양하다는 특성이 있으며, Dinomaly의 Linear Attention이 전체 이미지를 참조하도록 설계된 구조와 충돌할 가능성이 있다. 또한 ViT-Base/14의 최소 처리 단위(14×14 픽셀)보다 작은 결함은 패치 내에서 희석될 수 있다. 이는 추론이며, 검증을 위해서는 별도 실험이 필요하다. 참고로 같은 지표에서 UniAD는 93.5%를 기록한다 (Dinomaly 논문 Table A15).

## 출처
- SimpleNet 수치: Liu et al., SimpleNet (CVPR 2023), Table 1
- Dinomaly 수치: 재현 실험, `method4_dinomaly/source/results/dinomaly_mvtec_results.csv`
- Dinomaly 논문: Guo et al., Dinomaly (CVPR 2025)
