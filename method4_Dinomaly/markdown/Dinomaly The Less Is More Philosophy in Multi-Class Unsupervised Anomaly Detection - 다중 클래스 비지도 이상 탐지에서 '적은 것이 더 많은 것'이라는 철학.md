![[Dinomaly The Less Is More Philosophy in MultiClass Unsupervised Anomaly Detection.pdf]]

## 기존 UAD의 한계, Dinomaly가 푼 방식

### UAD의 두 가지 설정

**기존 UAD(Unsupervised Anomaly Detection, 비지도 이상탐지)는 클래스별로 모델을 따로 만드는 방식이었다.**

나사 탐지 모델, 카펫 탐지 모델, 병 탐지 모델을 각각 저장해두는 구조. 클래스 수가 늘어날수록 모델도 함께 늘어나 저장 비용이 기하급수적으로 증가함.

![[Pasted image 20260515210942.png|192]]
이를 해결하기 위해 등장한 것이 **MUAD(Multi-Class Unsupervised Anomaly Detection)** — 하나의 모델로 모든 클래스를 동시에 처리하는 방식. UniAD를 시작으로 활발히 연구되고 있음.

---

### MUAD의 핵심 난제: Identity Mapping

MUAD 설정에서 복원 기반(Reconstruction-based) 모델을 쓰면 치명적인 문제가 생김.

단일 클래스 모델이라면 "그 클래스의 정상 패턴"만 복원할 수 있어서, 불량이 들어오면 복원에 실패함 → 복원 오류로 이상 탐지 가능.

그런데 여러 클래스를 동시에 학습하면, 모델이 다양한 패턴에 노출되면서 **지나치게 일반화(over-generalization)** 됨. 결국 불량 패턴도 "처음 보는 정상 패턴이겠지"하고 그냥 복원해버림 → 이상 탐지 실패.

이를 **Identity Mapping**(입력을 그대로 출력으로 복사해버리는 현상)이라 부르며, Dinomaly는 이것을 **"over-generalization 문제"로 재정의**함.

---

### 기존 MUAD 방법들의 한계와 SimpleNet의 접점

기존 MUAD 연구들(UniAD, HVQ-Trans, DiAD 등)은 Identity Mapping을 막기 위해 벡터 양자화, 확산 모델, 이웃 마스킹 같은 복잡한 모듈을 추가하는 방향을 택함. 그럼에도 불구하고 class-separated 모델과의 성능 차이가 여전히 큼.

한편 SimpleNet처럼 합성 기반(Synthesizing-based) 방법은 정상 피처에 **고정된 Gaussian noise(σ=0.015)** 를 더해 가짜 불량을 생성하고 Discriminator를 학습시키는 방식으로 Identity Mapping 문제를 우회함. 단일 클래스 설정에서는 효과적이지만, 고정된 σ값이 카테고리마다 결함 분포를 균등하게 커버하지 못한다는 구조적 한계가 있음. 또한 노이즈 기반 가짜 불량 생성이라는 설계 자체가 heuristic(경험적 직관)에 의존하며, 도메인이나 데이터셋이 달라지면 범용성이 떨어짐.

![[Pasted image 20260515211326.png]]
---

### Dinomaly의 발상

> "복잡한 모듈이나 특별한 트릭 없이, 순수 Transformer 구조만으로 멀티클래스 이상탐지를 클래스별 전용 모델 수준까지 끌어올릴 수 있다."

Dinomaly는 새로운 모듈을 추가하는 대신, Transformer 구조에 이미 내장된 특성들을 올바르게 활용하는 방향을 선택함. Attention과 MLP 외에 아무것도 추가하지 않음.

---

## Dinomaly 상세 요약

### 1. 문제 정의

불량 샘플 없이 정상 샘플만으로 이상을 탐지해야 하는 비지도 학습 문제. 15~30개의 서로 다른 클래스를 하나의 모델로 동시에 커버하는 **MUAD 설정**에서 기존 방법들과 class-separated 모델 사이의 성능 gap을 줄이는 것이 핵심 목표.

---

### 2. 프레임워크 구조

![[Pasted image 20260515211358.png]]

Dinomaly는 **인코더 → 보틀넥 → 디코더** 구조의 복원 기반(Reconstruction-based) 프레임워크.

- **인코더**: 사전학습된 ViT(Vision Transformer). 파라미터 동결(freeze), 학습 안 함. 12개 레이어 중 중간 8개 레이어의 피처를 복원 목표로 사용
- **보틀넥**: MLP(Multi-Layer Perceptron, 여러 층으로 쌓인 완전 연결 신경망). 8개 레이어의 피처를 수집
- **디코더**: 8개의 Transformer 레이어

학습 중에는 디코더가 인코더의 중간 레이어 피처를 복원하도록 학습됨(cosine similarity 최대화). 추론 시에는 정상 영역은 잘 복원되지만, 학습 때 본 적 없는 불량 영역은 복원에 실패함 → 복원 오류(cosine distance)가 이상치 점수가 됨.

---

### 3. 핵심 구성요소 4가지

> "복잡한 것을 더하는 게 아니라, 이미 있는 것들을 올바르게 사용하는 것"

#### ① Foundation Transformer (기반 Transformer)

![](../Pasted%20image%2020260515211931.png)

- **DINOv2-Register로 사전학습된 ViT-Base/14** 를 인코더로 사용
- DINOv2는 대규모 데이터셋에서 자기지도학습(Self-Supervised Learning)으로 학습된 범용 시각 표현 모델
- 기존 이상탐지 연구들은 "모델이 클수록 성능이 오히려 떨어진다"고 보고했지만, Dinomaly에서는 **스케일링 법칙(Scaling Law)이 성립함** → ViT-Small < ViT-Base < ViT-Large 순으로 성능 향상
- **ImageNet linear-probing 정확도**(백본을 얼려두고 선형 분류기만 붙여서 측정하는 표현력 지표)가 높을수록 이상탐지 성능도 높게 나옴 → 더 좋은 사전학습 모델이 나올수록 Dinomaly도 자동으로 성능이 올라갈 가능성

#### ② Noisy Bottleneck

"Dropout is all you need."

기존 MUAD 연구들은 Identity Mapping을 막기 위해 pseudo anomaly나 feature noise를 손으로 설계했음(SimpleNet의 Gaussian noise, UniAD의 Feature Jitter 등). 이런 방식은 heuristic에 의존하고 도메인 범용성이 낮음.

Dinomaly는 그냥 **MLP 보틀넥에 이미 존재하는 Dropout을 켜는 것**으로 대체함.

- Dropout이 입력 정보를 랜덤하게 차단하면서, 디코더가 불완전한 정보로도 정상 피처를 복원하도록 강제됨 → 디노이징 오토인코더(Denoising Autoencoder)와 유사한 효과
- Dropout rate = 0.2 (Real-IAD처럼 클래스 다양성이 큰 데이터셋에서는 0.4로 증가)
- 논문(Table A8)에서 Feature Jitter와 직접 비교했을 때, Dropout이 하이퍼파라미터 변화에 더 강건한 성능을 보임

#### ③ Unfocused Linear Attention

"One man's poison is another man's meat."

![636](../Pasted%20image%2020260515212006.png)

Softmax Attention이 가진 약점을 역으로 활용하는 아이디어.

**Softmax Attention** (일반적인 Attention):

```
Attention(Q, K, V) = Softmax(QKᵀ)V
```

query와 가장 관련 있는 key 위치에 attention 가중치가 집중됨. → 자기 자신 위치에 집중하면 입력 정보를 그대로 다음 레이어로 넘기는 Identity Mapping 발생

**Linear Attention** (Softmax를 제거한 Attention):

```
LA(Q, K, V) = φ(Q)(φ(Kᵀ)V)
```

Softmax가 없어서 특정 위치에 집중하지 못하고, **전체 이미지에 걸쳐 attention이 균등하게 분산됨**. → 각 위치를 복원할 때 이미지 전체의 정보를 참조해야 함 → 입력 정보를 그대로 복사하는 shortcut이 자연스럽게 차단됨

- 감독 학습(Supervised) 태스크에서는 단점이었던 "집중 못 하는 특성"이, 이상탐지 복원 태스크에서는 오히려 장점으로 작용
- 계산 복잡도도 O(N²d) → O(Nd²)로 감소하는 부수 효과

#### ④ Loose Reconstruction

"The tighter you squeeze, the less you have."

![](../Pasted%20image%2020260515212030.png)

복원 제약을 의도적으로 느슨하게 만들어서 디코더에게 더 많은 자유도를 주는 아이디어.

**Loose Constraint (느슨한 제약)**

기존 방법들: 인코더의 특정 레이어 출력과 디코더의 대응 레이어 출력을 1:1로 맞춰야 함(layer-to-layer 감독). 레이어 쌍이 많아질수록 디코더가 인코더를 더 잘 모방하게 되어, 불량 패턴도 따라 복원해버림 → Identity Mapping 심화.

지식 증류(Knowledge Distillation) 관점에서 보면, layer-to-layer 감독이 많을수록 student(디코더)가 teacher(인코더)를 더 잘 모방함. 이상탐지에서는 이게 오히려 독임.

Dinomaly: 여러 레이어의 피처맵을 **그룹으로 합산(add)해서 하나로 묶어버림**. 2개 그룹(저수준 시각 특징 그룹 + 고수준 의미 특징 그룹)으로 나누어 group-to-group 복원. 레이어 간 1:1 대응이 사라지면서 디코더의 복원 방식에 자유도가 생김 → 처음 보는 패턴을 강제로 복원하려는 압력이 줄어듦.

**Loose Loss (느슨한 손실함수)**

Hard-mining Global Cosine Loss: 학습 중 이미 잘 복원된 포인트(cosine distance가 낮은 하위 k%)의 **gradient를 1/10으로 축소(shrink)**. 이미 잘 되고 있는 포인트에 계속 집중하는 대신, 어려운 포인트에 학습을 집중시킴 → 디코더가 정상 패턴을 너무 완벽하게 외우지 않도록 방지.

---

## 실험 결과

### 1. MUAD SOTA 비교

**MVTec-AD (15클래스), VisA (12클래스), Real-IAD (30클래스) 기준:**

|데이터셋|Dinomaly (Image AUROC)|이전 MUAD SOTA|향상폭|
|---|---|---|---|
|MVTec-AD|**99.6%**|98.6% (MambaAD)|+1.0%p|
|VisA|**98.7%**|95.5% (ReContrast)|+3.2%p|
|Real-IAD|**89.3%**|86.4% (ReContrast)|+2.9%p|

- MUAD 모델임에도 불구하고, **class-separated SOTA와 동등하거나 그 이상의 성능 달성**
- MVTec-AD 기준, MUAD Dinomaly(99.6%)와 class-separated Dinomaly(99.7%) 사이의 성능 차이가 0.1%p에 불과

### 2. Ablation Study

**각 구성요소 기여도 실험 (MVTec-AD 기준):**

|NB|LA|LC|LL|Image AUROC|
|---|---|---|---|---|
|||||98.41|
|✓||||99.06|
||✓|||98.54|
|✓|✓|||99.27|
|✓|✓|✓||99.52|
|✓|✓|✓|✓|**99.60**|

- NB(Noisy Bottleneck)의 기여가 가장 크고, 나머지 요소들이 그 위에 쌓이는 구조
- LC(Loose Constraint) 단독으로는 오히려 성능이 떨어짐 → NB 없이 복원 제약만 느슨하게 하면 복원이 너무 쉬워져서 이상 탐지 능력이 저하됨. NB와 함께 써야 의미 있음

### 3. 스케일링 실험

|백본|Params|Image AUROC (MVTec)|
|---|---|---|
|ViT-Small|37.4M|99.26%|
|ViT-Base|148.0M|99.60%|
|ViT-Large|275.3M|99.77%|

모델이 클수록 성능이 일관되게 향상됨. 기존 이상탐지 연구들이 "스케일링 법칙이 성립 안 한다"고 보고했던 것과 반대되는 결과.

### 4. 사전학습 백본 비교

![479](../Pasted%20image%2020260515212105.png)

- MAE를 제외한 거의 모든 사전학습 백본에서 I-AUROC 98% 이상 달성 → 백본 선택에 강건함
- MAE는 fine-tuning 없이는 여러 비지도 태스크에서 취약한 것으로 알려져 있으며, Dinomaly에서도 동일한 경향 관찰
- ImageNet linear-probing 정확도와 이상탐지 성능 사이의 강한 상관관계 확인 → 더 좋은 사전학습 모델이 등장할수록 Dinomaly도 자동으로 성능이 향상될 가능성

### 5. 시각화

![473](../Pasted%20image%2020260515212507.png)
![473](../Pasted%20image%2020260515212543.png)
![457](../Pasted%20image%2020260515212627.png)

---

## SimpleNet의 한계와 Dinomaly의 검증

SimpleNet이 논문 수준에서 내재하고 있는 구조적 한계들을 정리하고, Dinomaly가 이를 실제로 해결하는지 재현 실험 수치로 검증함.

---

### 한계 ① Synthetic Anomaly의 heuristic 의존성

SimpleNet의 Anomaly Feature Generator는 정상 피처에 **고정된 Gaussian noise(σ=0.015)** 를 더해 가짜 불량 피처를 생성함. 이 설계는 세 가지 구조적 문제를 내포함.

첫째, σ값이 전 카테고리에 단일 고정값으로 설정되어 있음. SimpleNet 논문(Figure 5)에서 σ에 따라 카테고리별 성능 편차가 발생하며, 이는 σ=0.015가 모든 카테고리의 결함 분포를 균등하게 커버하지 못함을 시사함.

둘째, SimpleNet 논문이 명시하듯 test set을 validation에 그대로 사용하는 구조로 설계되어 있음. 이는 검증 지표가 실제 일반화 성능을 과대 추정할 수 있음을 의미하며, 논문 수치의 신뢰성에 근본적인 의문을 남김.

셋째, Gaussian noise 기반의 가짜 불량 생성은 heuristic에 의존하는 방식으로, 도메인이나 데이터셋이 달라질 경우 범용성이 보장되지 않음.

**Dinomaly의 접근:** Noisy Bottleneck은 Gaussian noise를 외부에서 주입하는 대신, MLP 보틀넥 내부의 Dropout이 뉴런을 랜덤하게 비활성화하면서 노이즈 효과를 만들어냄. Discriminator를 학습시키지 않고 복원 오류(cosine distance) 자체를 이상치 점수로 사용하는 구조이므로, test/validation 혼용 문제가 구조적으로 발생하지 않음. 논문(Table A8)에서 Dropout이 Feature Jitter 대비 하이퍼파라미터 변화에 더 강건한 성능을 보임.

---

### 한계 ② Single-Class 전용 설계

SimpleNet은 클래스별로 모델을 따로 학습시키는 class-separated 설정만 지원함. 하나의 모델로 여러 클래스를 동시에 처리하는 MUAD 설정에서는 구조적으로 Identity Mapping 문제를 피하기 어려움.

**Dinomaly의 접근:** MUAD를 핵심 설계 목표로 삼으며, 15개 클래스를 하나의 모델로 학습해도 class-separated 전용 모델과 동등한 성능을 달성함. 논문 기준 MVTec-AD에서 MUAD Dinomaly(99.6%) vs class-separated Dinomaly(99.7%)로 차이가 0.1%p에 불과.

---

### 한계 ③ Localization 성능

SimpleNet은 Discriminator의 위치별 출력값을 anomaly map으로 사용하는 방식이라, 픽셀 단위 localization 정밀도에 한계가 있음. 논문 기준 MVTec-AD P-AUROC 98.1%로 PatchCore(98.1%)와 동등하지만, 구조적으로 위치 정보를 정밀하게 추론하기보다 전역적 판단에 의존하는 경향이 있음.

**Dinomaly의 접근:** 멀티스케일 피처를 2개 그룹으로 나누어 group-to-group 복원하고, 위치별 cosine distance를 anomaly map으로 사용함. 저수준 시각 특징 그룹이 정밀한 localization에 기여함.

---

### 재현 실험 비교표 (MVTec-AD 기준)

**전체 평균:**

|지표|PatchCore|SimpleNet|Dinomaly (논문)|Dinomaly (재현)|
|---|---|---|---|---|
|I-AUROC|99.1%|99.6%|**99.6%**|**99.62%**|
|P-AUROC|98.1%|98.1%|98.4%|**98.32%**|
|P-AUPRO|93.5%|90.0%|94.8%|**94.65%**|

**screw 카테고리 (핵심 비교):**

|모델|I-AUROC|P-AUROC|
|---|---|---|
|PatchCore|0.988|0.995|
|SimpleNet (논문)|0.982|0.993|
|**Dinomaly (재현)**|**0.985**|**0.996**|

screw에서 Dinomaly가 안정적으로 높은 성능을 보임. SimpleNet 논문 수치(0.982)와 비교해도 Dinomaly(0.985)가 소폭 우위.

---


## 코드 구현

### 환경 및 설정

- 플랫폼: Kaggle Notebook (NVIDIA Tesla T4, 30GB GPU)
- 데이터셋: MVTec-AD 15클래스 전체
- 백본: ViT-Base/14 (DINOv2-Register, 논문 기본값)
- iteration: 10,000 (논문 기본값)
- 수정사항: `utils.py`의 `df.append()` → `pd.concat()` (pandas 버전 호환성 패치)

### 실험 결과 (iter 10,000 최종)

|카테고리|I-AUROC|P-AUROC|P-AUPRO|
|---|---|---|---|
|carpet|0.9988|0.9934|0.9753|
|grid|0.9975|0.9940|0.9713|
|leather|1.0000|0.9934|0.9778|
|tile|1.0000|0.9809|0.9056|
|wood|0.9991|0.9759|0.9365|
|bottle|1.0000|0.9913|0.9668|
|cable|1.0000|0.9834|0.9392|
|capsule|0.9793|0.9868|0.9742|
|hazelnut|1.0000|0.9943|0.9706|
|metal_nut|1.0000|0.9686|0.9466|
|pill|0.9924|0.9783|0.9746|
|screw|0.9850|0.9964|0.9833|
|toothbrush|1.0000|0.9890|0.9517|
|transistor|0.9904|0.9305|0.7531|
|zipper|1.0000|0.9917|0.9704|
|**Mean**|**0.9962**|**0.9832**|**0.9465**|

논문 수치(I-AUROC 99.6%, P-AUROC 98.4%, P-AUPRO 94.8%) 대비 오차 범위 내에서 재현 성공.

### 느낀점 및 인사이트

**1. SimpleNet 대비 수렴 안정성**

SimpleNet은 screw 카테고리에서 I-AUROC가 epoch마다 진동하는 
불안정한 학습 패턴을 보인 반면 (epoch 160 기준 MAX 0.8949),
Dinomaly는 loss가 0.2052(iter 226)에서 0.0483(iter 10000)으로 
단조 감소하며 안정적으로 수렴함.

**2. MUAD 설정의 실효성**

15개 클래스를 하나의 모델로 학습했음에도 논문 수치를 재현했다는 것은, Dinomaly가 MUAD 설정에서 class-separated 모델과의 성능 gap을 실질적으로 좁혔음을 직접 확인한 것.

**3. 계산 비용**

Kaggle T4 기준 10,000 iteration에 약 7시간 소요. SimpleNet의 160 epoch(약 6시간)과 유사한 수준이지만, Dinomaly는 15개 클래스 전체를 동시에 처리한 결과라는 점에서 클래스당 비용은 오히려 낮음.
