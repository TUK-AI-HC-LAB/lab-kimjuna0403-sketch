  ![[산업용 이상 탐지에 있어서의 완전한 재현율을 향하여.pdf]]
  
 

# 쉬운 설명

## 1. 문제 정의

공장에서 제품이 정상인지 불량인지 판별하는 AI를 만들고자 한다. 하지만 정상 제품 사진은 구하기 쉽지만, 불량품은 발생 빈도가 낮고 종류가 너무 다양해서 모든 유형을 학습시키기가 어렵다. 기스, 파손, 부품 누락 등 예상치 못한 모든 결함을 다룰 수 없다는 것이 큰 문제이다. 그래서 이 논문은 정상 제품이 어떻게 생겼는지만 공부해서, 거기서 조금이라도 벗어나면 불량이라고 판단하는 '콜드 스타트(Cold-start)' 전략을 세운다.

## 2. 핵심 작동 방식

### ① "정상의 기준"을 아주 자세히 쪼개서 기억하기

- AI에게 정상 제품 사진을 보여줄 때 사진 한 장을 통째로 보지 않고 작은 조각(패치)으로 나누어서 관찰한다.
    
- 단순히 한 점의 특징만 보는 것이 아니라 주변 정보를 함께 고려하는 '국소 이웃 집계(Local Neighbourhood Aggregation)'를 통해 특징을 뽑아낸다.
    
- 이렇게 추출한 정상 패치들의 정보를 한데 모아 **메모리 뱅크(Memory Bank)**에 저장한다.
    

### ② "핵심 요약 노트" 만들기 (Coreset Subsampling)

- 정상 패치 조각을 모두 저장하면 데이터가 너무 많아져서 나중에 비교할 때 시간이 너무 오래 걸린다.
    
- 그래서 중복되거나 뻔한 정보는 버리고 전체 데이터의 기하학적 구조를 가장 잘 대표하는 핵심 조각들만 골라내는 **코어셋(Coreset)** 기술을 사용한다.
    
- 데이터를 1% 수준으로 대폭 줄여도 성능을 유지하면서 저장 공간과 추론 시간을 획기적으로 단축한다.
    

### ③ "틀린 그림 찾기" (Anomaly Detection)

- 새로운 제품 사진이 들어오면 각 패치를 아까 만든 '요약 노트'와 하나씩 비교한다.
    
- 테스트 패치가 메모리 뱅크 내의 어떤 정상 데이터와도 거리가 너무 멀다면 이를 불량으로 판정한다.
    
- 단순히 판정만 하는 것이 아니라 이미지 어디가 이상한지 정확한 위치를 표시해주는 **세그멘테이션(Segmentation)** 결과까지 제공한다.
    

## 3. 효과

- **공부 효율**: 정상 제품 사진이 아주 적은 상황(Low-shot)에서도 기존 모델보다 훨씬 뛰어난 성능을 보여준다.
    
- **눈썰미**: 미세한 흠집부터 큰 구조적 결함까지 모두 잡아내며, MVTec AD 벤치마크에서 99.6%라는 압도적인 점수를 기록한다.
    
- **속도**: 정보를 요약해서 저장했기 때문에 실제 공장 라인에서 즉각적으로 검사할 수 있을 만큼 빠르다.
    

요약하자면, **정상의 모습을 작은 단위로 쪼개서 기억해 뒀다가 실제 검사할 때 요약된 장부와 비교해 틀린 부분을 찾아내는 기술이다.**


# 세부 요약

## 언어 설명

1) cold start : 데이터나 정보가 없는 초기 상태에서 시스템, 모델, 서비스가 가동되거나 작동하기 어려움을 겪는 현상
2) ImageNet : 컴퓨터 비전(시각적 인지) 연구 및 인공지능 모델 훈련을 위해 구축된 **대규모 이미지 데이터베이스** 
3) Patch-features : 이미지를 작은 조각(Patch) 단위로 나눈 후, 각 조각에서 추출한 국소적(Local)이고 고차원적인 정보(벡터 표현)
4) Mid-level: 심층 신경망(CNN 등)의 전체 구조 중에서 입력에 가까운 '초반부'도 아니고 최종 출력에 가까운 '최상단부'도 아닌, **네트워크의 중간 단계에서 추출된 데이터 형상**
   -> 중간층을 사용하는 이유는 ? 
- **저수준(Low-level) 특징**: 선, 색상, 점과 같은 단순한 기하학적 형태를 파악
    
- **중간층(Mid-level) 특징**: 사물의 부분적인 모양이나 질감(Texture) 등 적당한 크기의 국부적인 패턴을 파악
    
- **고수준(High-level) 특징**: 사물의 전체적인 형태나 추상적인 개념(예: '강아지', '자동차')을 파악
  ResNet-50과 같은 구조로 주로 Block 2와 Block 3의 마지막 출력물을 중간층 특징으로 사용
  너무 깊은 층은 해상도 소실의 문제. 정밀한 결함 위치를 찾기 어려움. 또한 모델이 원래 학습했던 데이터에 너무 최적화 되어있음 따라서 중간층의 패치 단위 특징은 이러한 미세 변화를 가장 잘 담아낼 수 있다. 
  *PatchCore* 는 이 중간층 특징들을 추출한 뒤, Neighborhood Aggregation을 통해 각 패치가 주변의 맥락 정보까지 포함하도록 한다. 
1) MVTec AD : 산업 현장의 실질적인 어려움을 해결하기 위해 만들어진 **표준 데이터셋** ( 비지도학습의 성능을 평가하기 위함 )
2) AUROC 곡선으로는 모델이 얼마나 이상치(불량)을 잘 분류하는지 나타냄
3) Local Neighborhood Aggregation : (해당 논문에서는 p=3으로 영역 설정) :
- **영역 설정 ($p=3$)**: 특정 패치 하나만 보는 게 아니라, 그 패치를 중심으로 $3 \times 3$ 크기의 '이웃' 영역을 정함
    
- **Adaptive Average Pooling (집계)**: 이 $3 \times 3$ 영역 안에 있는 특징 값들의 **평균**을 내어 하나의 대표값으로 합친다. 
    
    - 이 과정이 마치 '주변 정보와 섞여서 부드러워지는 효과(Local Smoothing)'를 준다. 
        
- **수용 영역(Receptive Field) 확장**: 결과적으로 하나의 패치가 원래보다 더 넓은 범위를 대변하게 됨.  -> 이 기술 덕분에 노이즈에 강하면서도 정확한 탐지가 가능해진다고 한다. 
 1) Greedy Coreset Subsampling : 전체 데이터 중에서 가장 대표성이 있는 소수 (1%~10%)만 골라내는 작업, 단순히 랜덤하게 뽑는것이 아닌 원래 데이터의 모양을 최대한 그대로 유지하도록 뽑는것이 기술 
 2) Random Linear Projection (Johnson-Lindenstrauss 정리 활용) : 고차원의 데이터를 낮은 차원으로 무작위로 투영(Projection)시켜도, 데이터 간의 거리 관계는 어느 정도 유지된다"는 수학적 이론 -> 아주 긴 숫자 배열이었던 특징값들을 무작위 행렬과 곱해서 짧은 숫자 배열로 압축한다. 계산 속도가 비약적으로 빨라짐 
 - 둘의 차이는.. 각 반의 뚜렷한 대표 몇명만 뽑자 vs 뽑는것도 복잡하니까 핵심 위주로 차원축소해서 요약하자
 
1) Anomaly Score : 테스트하려는 새로운 이미지에서 뽑아낸 패치 특징들을 메모리 뱅크($\mathcal{M}$)에 저장된 정상 데이터들과 하나하나 비교 
2) Re-weighting : 단순히 거리만 재면, 정상 데이터 중에서도 아주 가끔 나타나는 특이한 케이스 때문에 모델이 헷갈릴 수 있으므로. 이를 방지하기 위해 **점수를 보정** -> 희귀성 체크 후에 최종 이상치 점수를 더 높게 책정한다. 
3) Localization : 어디가 불량인지 그리기 
- **정렬 및 매핑**: 각 패치별로 계산된 이상치 점수들을 원래 이미지의 위치(좌표)에 그대로 배치한다.
    
- **바이리니어 보간 (Bilinear Interpolation)**: 패치 단위로 점수를 매기다 보니 결과물이 모자이크처럼 깍두기 모양일 수 있다. 이를 부드럽게 늘려서 원래 이미지 해상도와 맞춘다.
    
- **가우시안 평활화 (Gaussian Smoothing)**: 점수들이 너무 튀지 않도록 가우시안 필터($\sigma=4$)를 적용해 자기 자신은 높게 반영하고 주변 픽셀은 거리에 따라 점점 낮게 반영하여 평균을 내어어 부드러운 열지도(Heatmap) 형태로 만든다. 
 -----------------------------------------------------------------------
 
## 1. 개요 (Abstract & Introduction)

- **목적**: 산업 현장에서 정상 데이터(Nominal)만으로 모델을 학습시켜 결함(Anomaly)을 찾아내는 'Cold-start' 이상 탐지 해결.
    
- **핵심 아이디어**: ImageNet으로 사전 학습된 모델의 **중간층(Mid-level) 특징(Patch-features)**을 활용하여, 정상 이미지의 특징을 담은 **메모리 뱅크(Memory Bank)**를 구축.
    
- **성과**: MVTec AD 벤치마크에서 이미지 레벨 AUROC **99.6%**를 기록하며 기존 성능을 압도적으로 경신.
    

---

## 2. 주요 방법론 (Methodology)

#### 2.1 Locally Aware Patch Features (Section 3.1)

- **특징 추출**: ResNet 계열의 백본 네트워크에서 너무 추상적이지 않은 중간 계층($j \in \{2, 3\}$)의 특징 맵을 사용함. 이는 ImageNet 클래스에 대한 편향을 줄이고 국부적인 정보를 보존하기 위함임.
    
- **국부 이웃 집계(Local Neighborhood Aggregation)**: 각 패치를 볼 때 해당 위치 하나만 보는게 아니라. 특징에 대해 주변 이웃(Neighborhood size $p=3$ 권장)의 특징을 Adaptive Average Pooling으로 집계하여 수용 영역(Receptive Field)을 넓히고 공간적 변동에 대한 강건성을 확보함.
    

#### 2.2 Coreset-Reduced Memory Bank (Section 3.2)

- **필요성**: 모든 정상 패치를 저장하면 메모리 사용량과 추론 시간이 급격히 증가함.
    
- **알고리즘**: **Greedy Coreset Subsampling**을 도입하여 원래 특징 공간의 분포(Coverage)를 최대한 유지하면서 메모리 뱅크의 크기를 1%~10% 수준으로 획기적으로 줄임.
    
- **차원 축소**: 검색 속도를 더 높이기 위해 Johnson-Lindenstrauss 정리를 기반으로 한 무작위 선형 투영(Random Linear Projection)을 사용하여 특징의 차원을 낮춤.
    
#특징추출 -> #차원축소 -> #대표선발 -> #최종저장 의 순서로 진행 
#### 2.3 Anomaly Detection & Localization (Section 3.3)

- **이상치 점수(Anomaly Score)**: 테스트 이미지의 패치 특징들과 메모리 뱅크 내 가장 가까운 이웃($m^*$) 사이의 최대 거리를 기반으로 산출함.
    
- **재가중치(Re-weighting)**: 가장 가까운 이웃 특징 $m^*$이 그 주변 이웃들과도 거리가 멀 경우(이미 희귀한 경우) 점수를 높여 강건성을 부여함.
    
- **세그멘테이션(Localization)**: 각 패치의 점수를 원래 공간 위치에 맞게 정렬한 후 바이리니어 보간(Bilinear Interpolation)과 가우시안 평활화(Gaussian Smoothing)를 거쳐 어디가 이상한지 히트맵으로 표시함함
    

---

## 3. 실험 결과 (Experiments)

#### 3.1 성능 지표 (MVTec AD)

- **이미지 레벨 AUROC**: PatchCore-25% 기준 **99.1%**, 앙상블 및 고해상도 적용 시 **99.6%** 달성.
    
- **픽셀 레벨 AUROC (Localization)**: **98.1%**로 기존 모델(PaDiM, SPADE 등)보다 우수함.
    
- **추론 속도**: Coreset 샘플링 덕분에 PaDiM보다 빠르면서도 성능은 월등히 높음 (1% 샘플링 시 이미지당 약 0.17초).
    

#### 3.2 데이터 효율성 (Low-shot Regime)

- 정상 이미지가 **1~5장**뿐인 극한의 상황에서도 타 모델 대비 매우 높은 성능과 효율성을 보임.
    

---

## 4. 결론 및 한계 (Conclusion & Limitations)

- **장점**: 별도의 학습(Training) 과정 없이 사전 학습된 특징만으로 즉시 적용 가능하며, 산업 현장의 요구 사항인 '고성능'과 '빠른 추론'을 동시에 충족함.
    
- **한계**: 사전 학습된 모델의 특징 전이성(Transferability)에 의존하므로, 특수 도메인에서는 해당 도메인 데이터에 맞춘 특징 적응(Adaptation)이 추가로 필요할 수 있음.


# 코드 구현

코드 구현 분석

### 1. 패치 피처 추출 (`patchcore.py`)

#### 1.1 PatchMaker - 패치 생성

python

```python
unfolder = torch.nn.Unfold(
    kernel_size=self.patchsize,  # p=3
    stride=self.stride,          # s=1
    padding=padding,
)
```

- 논문 수식 (3)의 Ps,p(ϕi,j)\mathcal{P}_{s,p}(\phi_{i,j}) Ps,p​(ϕi,j​) 를 구현한 부분
- 이미지의 각 위치에서 3×3 이웃 패치를 슬라이딩 윈도우 방식으로 추출
- padding을 줘서 **가장자리 픽셀도 빠짐없이 패치로 처리**됨

#### 1.2 _embed() - 다중 계층 피처 합산

python

```python
# layer3 피처를 layer2 해상도로 맞춤
_features = F.interpolate(
    _features.unsqueeze(1),
    size=(ref_num_patches[0], ref_num_patches[1]),
    mode="bilinear",
    align_corners=False,
)
# 두 계층 합산 후 차원 통일
features = self.forward_modules["preprocessing"](features)
features = self.forward_modules["preadapt_aggregator"](features)
```

- 논문 §3.1에서 말한 **"두 계층 j, j+1을 bilinear rescaling으로 합친다"** 는 부분을 직접 구현
- layer2(고해상도, 세밀한 정보) + layer3(저해상도, 넓은 맥락) 를 같은 크기로 맞춰 합산
- `Preprocessing` → `Aggregator` 순으로 통과하면서 최종 **1024차원** 피처 벡터로 정규화됨

#### 1.3 _fill_memory_bank() - 메모리 뱅크 구성

python

```python
features = []
for image in data_iterator:
    features.append(_image_to_features(image))

features = np.concatenate(features, axis=0)
features = self.featuresampler.run(features)  # Coreset 적용
self.anomaly_scorer.fit(detection_features=[features])
```

- 모든 정상 이미지를 순회하며 패치 피처 추출 → 한꺼번에 합산
- `featuresampler.run()` 으로 Coreset 서브샘플링 적용 후 메모리 뱅크에 저장
- **학습(Training) 과정이 이게 전부** → 별도 역전파(Backpropagation) 없음

---

### 2. Coreset 서브샘플링 (`sampler.py`)

#### 2.1 _reduce_features() - 차원 축소

python

```python
mapper = torch.nn.Linear(
    features.shape[1],                    # 원래 차원 (1024d)
    self.dimension_to_project_features_to, # 축소 차원 (128d)
    bias=False
)
return mapper(features)
```

- 논문에서 언급한 **Johnson-Lindenstrauss 정리** 기반 랜덤 선형 투영 구현
- 1024차원 → 128차원으로 압축해서 이후 거리 계산 속도를 비약적으로 향상
- `bias=False` 인 이유 : 순수하게 방향성(거리 관계)만 보존하기 위함

#### 2.2 _compute_greedy_coreset_indices() - 핵심 포인트 선별

python

```python
for _ in range(num_coreset_samples):
    # 현재 코어셋에서 가장 먼 포인트 선택
    select_idx = torch.argmax(approximate_coreset_anchor_distances).item()
    coreset_indices.append(select_idx)
    
    # 선택된 포인트와의 거리로 업데이트
    approximate_coreset_anchor_distances = torch.min(
        approximate_coreset_anchor_distances, dim=1
    ).values
```

- 논문 수식 (5)의 **minimax facility location** 을 greedy하게 근사한 구현
- 매 반복마다 **"현재 선택된 코어셋과 가장 멀리 있는 포인트"** 를 추가
- `torch.min()` 으로 각 포인트가 코어셋에서 얼마나 떨어져 있는지를 계속 갱신
- 결과적으로 **전체 데이터 분포를 가장 고르게 커버하는 소수의 포인트**만 남음

#### 2.3 ApproximateGreedyCoresetSampler - 근사 버전

python

```python
# 전체 N×N 거리 행렬 대신 랜덤 시작점 기반 근사 계산
start_points = np.random.choice(len(features), number_of_starting_points)
approximate_distance_matrix = self._compute_batchwise_differences(
    features, features[start_points]
)
```

- 정확한 Greedy Coreset은 **N×N 거리 행렬**이 필요 → 메모리 폭발
- 랜덤 시작점 10개만 골라서 근사 거리를 계산하는 방식으로 **메모리와 속도 동시 절약**
- 실제 실행 시 사용된 버전 (`approx_greedy_coreset` 옵션)

---

### 3. 이상 탐지 & 세그멘테이션 (`common.py`)

#### 3.1 NearestNeighbourScorer.predict() - 이상치 점수 계산

python

```python
query_distances, query_nns = self.imagelevel_nn(query_features)
anomaly_scores = np.mean(query_distances, axis=-1)
```

- 논문 수식 (6) 구현 : 테스트 패치와 메모리 뱅크 간 **kNN 거리** 계산
- FAISS 라이브러리로 대규모 벡터 유사도 검색을 GPU 수준으로 빠르게 처리
- 가장 가까운 정상 패치와의 거리가 멀수록 → **이상치 점수 높아짐**

#### 3.2 PatchMaker.score() - 이미지 레벨 스코어

python

```python
while x.ndim > 1:
    x = torch.max(x, dim=-1).values
```

- 논문의 핵심 아이디어 **"패치 하나라도 이상하면 이미지 전체가 이상"** 을 구현
- 모든 패치 점수 중 **최댓값**을 이미지의 최종 이상치 점수로 사용
- 단 한 곳의 결함도 놓치지 않겠다는 설계 철학

#### 3.3 RescaleSegmentor - 결함 위치 시각화

python

```python
# 패치 점수맵을 원본 이미지 크기로 업스케일
_scores = F.interpolate(_scores, size=self.target_size, mode="bilinear")

# 가우시안 평활화 (σ=4)
ndimage.gaussian_filter(patch_score, sigma=self.smoothing)
```

- 28×28 패치 스코어맵 → 224×224 원본 해상도로 **bilinear interpolation** 으로 확대
- 가우시안 필터(σ=4)로 경계가 부드러운 **히트맵(Heatmap)** 형태로 변환
- 논문 Figure 1의 오렌지색 결함 경계선이 바로 이 과정의 결과물

---

### 4. 전체 흐름 요약

```
[학습]
정상 이미지 
→ WideResNet50 layer2, layer3 피처 추출 (_embed)
→ 패치 단위로 분할 (PatchMaker.patchify)
→ Greedy Coreset으로 1% 압축 (ApproximateGreedyCoresetSampler)
→ FAISS 인덱스에 저장 (NearestNeighbourScorer.fit)

[추론]
테스트 이미지
→ 동일한 피처 추출 과정
→ 메모리 뱅크와 kNN 거리 계산 (NearestNeighbourScorer.predict)
→ 최대 패치 거리 = 이미지 이상치 점수 (PatchMaker.score)
→ 업스케일 + 가우시안 평활화 = 세그멘테이션 맵 (RescaleSegmentor)
```


![[Pasted image 20260414231612.png]]
**instance_auroc 1.000** → bottle 테스트 이미지 전체에서 정상/불량 분류를 **단 한 장도 틀리지 않았다**는 뜻. 완벽한 분류.

**full_pixel_auroc 0.985** → 전체 픽셀 기준으로 이상한 위치를 98.5% 정확도로 찾아냄. 정상 픽셀 포함 전체 대상.

**anomaly_pixel_auroc 0.980** → 실제로 결함이 있는 픽셀 영역만 따로 봤을 때 98.0% 정확도. 결함 부위를 얼마나 정확히 찾았는지의 지표.
![[Pasted image 20260414231915.png]]
### broken_small (작은 파손)

- 원본을 보면 병 뚜껑 테두리에 **아주 작은 파손**이 있음 
- 히트맵에서 **해당 위치가 밝게 표시**되고 있어 → 미세한 결함도 잡아냄
- 다만 뚜껑 전체 영역이 전반적으로 밝은데, 이건 병 뚜껑의 원형 패턴 자체가 정상 이미지와 미묘하게 달라서 넓게 반응한 것

### broken_large (큰 파손)

- 원본에 **유리 파편이 보이는 큰 파손**이 있음
- 히트맵에서 **파손 위치 근처가 가장 밝게(노란색)** 표시됨 → 큰 결함은 더 강하게 반응
- broken_small보다 히트맵이 더 밝고 집중적으로 나타남 → 결함 크기에 비례해서 이상치 점수가 높아지는 것

### contamination (오염)

- 원본에 병 표면에 **이물질(오염)**이 묻어있음
- 히트맵에서 **오염된 부위가 밝게** 표시됨
- 오버레이 보면 오염 위치와 히트맵 밝은 부분이 잘 일치함

### good (정상)

- 원본은 **결함 없는 정상 병**
- 근데 히트맵이 완전히 어둡지 않고 **링 형태로 약하게 밝음*
- 이건 오류가 아니야. 병 뚜껑의 나사선 패턴이 학습 이미지마다 미세하게 위치가 달라서 완전히 0점은 안 나오는 것. 중요한 건 **결함 이미지들보다 훨씬 낮은 점수**라는 것 