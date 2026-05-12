# 후속 논문 조사: 세 모델 한계 매핑
**작성자:** 김준아 (TUK AI-HC Lab)  
**작성일:** 2026-05-10  
**참고 분석:** `analysis/comparison_analysis.md`

---

## 0. 배경: 세 모델의 핵심 한계 요약

| 모델 | 핵심 한계 |
|---|---|
| PatchCore | 느린 추론 속도 (~6 FPS), 데이터 증가 시 메모리 뱅크 증가 |
| SimpleNet | 카테고리별 학습 불안정 (screw 수렴 실패 직접 확인), Gaussian noise 기반 가짜 불량의 한계 |
| Reverse Distillation | 맥락적(logical) 결함 취약, OCBE의 이상 신호 차단 명시적 보장 없음, ImageNet 도메인 편향 |

---

## 1. PatchCore 한계를 보완한 논문

---

### 1-1. FastFlow (arXiv 2021)
📄 https://arxiv.org/abs/2111.07677

**해결하는 한계:** PatchCore의 느린 추론 속도, 메모리 뱅크 의존성

**핵심 아이디어:**
2D Normalizing Flow로 정상 피처 분포를 확률 모델로 학습한다. PatchCore의 kNN 검색 없이 테스트 시 forward pass 한 번으로 이상 점수를 바로 계산하므로 메모리 뱅크가 필요 없다. ResNet, Vision Transformer 등 다양한 백본에 plug-in으로 사용 가능하다. MVTec AD 기준 I-AUROC 99.4% 달성.

**한계:** Normalizing Flow 특성상 학습 속도가 느리다.

---

### 1-2. EfficientAD (WACV 2024)
📄 https://arxiv.org/abs/2303.14535

**해결하는 한계:** PatchCore의 느린 추론 속도 + RD의 맥락적(logical) 결함 취약성

**핵심 아이디어:**
경량 Student-Teacher 구조로 2ms 레이턴시, 600 FPS를 달성한다. 논문에서 직접 명시한 내용: *"we address the detection of challenging logical anomalies that involve invalid combinations of normal local features, for example, a wrong ordering of objects. We detect these anomalies by efficiently incorporating an autoencoder that analyzes images globally."* 즉 Autoencoder를 추가하여 Student-Teacher가 잡지 못하는 글로벌 맥락 결함(부품 순서 이상 등)을 탐지한다.

---

### 1-3. RealNet (CVPR 2024)
📄 https://arxiv.org/abs/2403.05897

**해결하는 한계:** PatchCore의 피처 중복/편향 + SimpleNet의 비현실적 합성 불량

**핵심 아이디어:**
세 가지 핵심 모듈로 구성된다. (1) **SDAS(Strength-controllable Diffusion Anomaly Synthesis):** Diffusion 모델로 강도를 조절할 수 있는 현실적인 불량 샘플을 생성한다. (2) **AFS(Anomaly-aware Features Selection):** 사전학습 피처 중 대표적이고 판별력 있는 부분집합만 선택하여 계산 비용을 줄인다. (3) **RRS(Reconstruction Residuals Selection):** 다중 수준의 결함 영역을 포괄적으로 식별하기 위해 판별력 있는 잔차를 적응적으로 선택한다.

**한계:** Diffusion 모델을 사용하므로 학습 비용이 높다.

---

## 2. SimpleNet 한계를 보완한 논문

---

### 2-1. DRAEM (ICCV 2021)
📄 https://arxiv.org/abs/2108.07610

**해결하는 한계:** SimpleNet의 Gaussian noise 기반 가짜 불량 한계

**핵심 아이디어:**
외부 텍스처 데이터셋(DTD)에서 패턴을 가져와 이미지 공간에서 정상 이미지 위에 합성하여 가짜 불량을 만든다. 재구성 네트워크(복원)와 판별 네트워크(분류)를 동시에 학습시켜 "정상으로 복원한 이미지 vs 원본"의 차이를 이상 점수로 사용한다. SimpleNet 이전에 나왔지만 이후 합성 기반 논문들의 출발점이 되었다.

**한계:** 외부 텍스처 데이터셋(DTD)이 반드시 필요하다.

---

### 2-2. DeSTSeg (CVPR 2023)
📄 https://arxiv.org/abs/2211.11317

**해결하는 한계:** SimpleNet의 noise 한계 + localization 부족

**핵심 아이디어:**
DTD와 Perlin Noise를 섞어 만든 가짜 불량 이미지를 Student에게 입력하고, Teacher의 깨끗한 이미지 피처를 복원하도록 학습시키는 Denoising Student-Teacher 방식을 도입한다. 멀티스케일 피처를 적응적으로 융합하는 Segmentation 헤드를 추가하여 localization 정밀도를 높였다. MVTec AD 기준 image-level AUC 98.6% 달성.

**한계:** DTD 외부 데이터셋 의존성이 여전히 남아있다.

---

### 2-3. SuperSimpleNet (ICPR 2024)
📄 https://arxiv.org/abs/2408.03143

**해결하는 한계:** SimpleNet의 학습 불안정성, localization 부족

**핵심 아이디어:**
SimpleNet의 직접적인 후속작이다. 논문에서 명시한 기여: (1) SimpleNet 대비 학습 일관성(training consistency) 향상, (2) Gaussian noise 대신 Perlin Noise 기반 합성으로 더 구조적인 가짜 불량 생성, (3) 비지도(정상만)와 지도(불량 레이블 있음) 학습을 하나의 프레임워크로 통합, (4) Segmentation 헤드 추가로 localization 개선. MVTec AD 기준 I-AUROC 98.4% 달성.

---

## 3. Reverse Distillation 한계를 보완한 논문

---

### 3-1. RD++ (CVPR 2023)
📄 https://openaccess.thecvf.com/content/CVPR2023/html/Tien_Revisiting_Reverse_Distillation_for_Anomaly_Detection_CVPR_2023_paper.html

**해결하는 한계:** RD의 OCBE 이상 신호 차단 명시적 보장 없음

**핵심 아이디어:**
RD의 OCBE는 정상 데이터만으로 학습하기 때문에 이상 신호를 차단한다는 보장이 명시적으로 없다. RD++는 두 가지로 이를 해결한다. (1) Simplex Noise로 가짜 불량을 생성하여 Bottleneck이 이상 신호를 명시적으로 차단하도록 학습시킨다. (2) Self-supervised Optimal Transport로 피처 공간의 compactness를 강화한다. 논문에서 명시: PatchCore보다 6배 빠르고 메모리 4GB만 필요하면서 RD 대비 성능 향상.

---

### 3-2. ReContrast (NeurIPS 2023)
📄 https://arxiv.org/abs/2306.02602

**해결하는 한계:** RD의 ImageNet 도메인 편향, Teacher 고정으로 인한 도메인 불일치

**핵심 아이디어:**
RD는 Teacher Encoder를 완전히 고정(freeze)하여 ImageNet 도메인 편향이 해소되지 않는다. ReContrast는 대조 학습(Contrastive Learning) 원소를 피처 재구성에 내장하여 Encoder와 Decoder를 동시에 목표 도메인에 맞게 학습시킨다. 논문에서 명시: pattern collapse, identical shortcut 같은 학습 불안정성을 방지하면서 산업 및 의료 이미지 도메인 양쪽에서 SOTA 달성.

---

### 3-3. EfficientAD (WACV 2024)
📄 https://arxiv.org/abs/2303.14535

**해결하는 한계:** RD의 맥락적(logical) 결함 취약성

*(§1-2와 동일 논문)*

RD는 논문에서 직접 transistor 카테고리의 misplaced 결함에서 성능이 저하됨을 인정했다 [RD, §4.1 Limitations]. EfficientAD는 Autoencoder로 이미지를 글로벌하게 분석하여 이 한계를 해결한다.

---

## 4. 전체 매핑 요약표

| 논문 | 학회/연도 | 해결하는 모델 | 해결하는 한계 | I-AUROC (MVTec) |
|---|---|---|---|---|
| FastFlow | arXiv 2021 | PatchCore | 속도/메모리 뱅크 | 99.4% |
| EfficientAD | WACV 2024 | PatchCore + RD | 속도 + logical 결함 | - |
| RealNet | CVPR 2024 | PatchCore + SimpleNet | 피처 편향 + noise 한계 | - |
| DRAEM | ICCV 2021 | SimpleNet | noise 한계 | - |
| DeSTSeg | CVPR 2023 | SimpleNet | noise 한계 + localization | 98.6% |
| SuperSimpleNet | ICPR 2024 | SimpleNet | 학습 불안정 + localization | 98.4% |
| RD++ | CVPR 2023 | RD | OCBE 보장 없음 | - |
| ReContrast | NeurIPS 2023 | RD | 도메인 편향 | - |

---

## 5. method4 후보 검토

**선정 기준:**
- 세 모델 중 2개 이상의 한계를 동시에 해결하는가
- 공식 코드가 있고 MVTec에서 재현 가능한가
- 기존 구현 모델과 구조적 연속성이 있는가

| 논문 | 해결 모델 수 | 공식 코드 | 구조 연속성 |
|---|---|---|---|
| EfficientAD | PatchCore + RD (2개) | ✅ | ✅ S-T 구조 (RD와 동일 계열) |
| RealNet | PatchCore + SimpleNet (2개) | ✅ | △ Diffusion 모델 새로 필요 |
| SuperSimpleNet | SimpleNet (1개) | ✅ | △ Discriminator 구조 |

*최종 선정은 미팅에서 교수님과 논의 예정*

---

## 참고문헌

[1] Yu, J., et al. FastFlow: Unsupervised Anomaly Detection and Localization via 2D Normalizing Flows. arXiv:2111.07677 (2021)
[2] Batzner, K., et al. EfficientAD: Accurate Visual Anomaly Detection at Millisecond-Level Latencies. WACV 2024. arXiv:2303.14535
[3] Zhang, X., et al. RealNet: A Feature Selection Network with Realistic Synthetic Anomaly for Anomaly Detection. CVPR 2024. arXiv:2403.05897
[4] Zavrtanik, V., et al. DRAEM – A Discriminatively Trained Reconstruction Embedding for Surface Anomaly Detection. ICCV 2021. arXiv:2108.07610
[5] Zhang, X., et al. DeSTSeg: Segmentation Guided Denoising Student-Teacher for Anomaly Detection. CVPR 2023. arXiv:2211.11317
[6] Rolih, B., et al. SuperSimpleNet: Unifying Unsupervised and Supervised Learning for Fast and Reliable Surface Defect Detection. ICPR 2024. arXiv:2408.03143
[7] Tien, T. D., et al. Revisiting Reverse Distillation for Anomaly Detection. CVPR 2023.
[8] Guo, J., et al. ReContrast: Domain-Specific Anomaly Detection via Contrastive Reconstruction. NeurIPS 2023. arXiv:2306.02602
