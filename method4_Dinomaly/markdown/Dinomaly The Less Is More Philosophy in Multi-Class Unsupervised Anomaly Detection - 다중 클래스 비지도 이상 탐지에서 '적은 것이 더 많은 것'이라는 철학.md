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

## 결론 및 한계

**장점:**

- Attention과 MLP만으로 구성된 순수 Transformer 구조 → 추가 모듈 없음
- 기존 MUAD 방법들을 큰 폭으로 상회하면서, class-separated 전용 모델과 동등한 성능
- 스케일링이 가능해서 계산 자원에 따라 모델 크기와 입력 해상도를 유연하게 조절 가능
- SimpleNet, UniAD 등이 의존하는 heuristic한 노이즈 설계 없이 Dropout 하나로 대체

**한계:**

- ViT 특성상 계산 비용이 높음 → FlashAttention, 지식 증류(distillation), 가지치기(pruning) 등으로 개선 여지 있음
- **Sensory AD** (같은 물체의 표면/구조 결함 탐지) 전용. **Semantic AD** (정상과 이상이 아예 다른 클래스인 경우, 예: 동물 vs 차량)에는 적합하지 않음
- Zero-shot UAD(비전-언어 모델 기반), Few-shot UAD, 노이즈 포함 학습셋 설정은 다루지 않음