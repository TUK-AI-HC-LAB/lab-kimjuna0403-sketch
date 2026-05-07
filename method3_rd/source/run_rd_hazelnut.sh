#!/bin/bash
# RD4AD hazelnut 실험
# 실행 환경: Kaggle Notebook T4 GPU
# 실행 노트북: method3/source/run_rd_hazelnut.ipynb
# 데이터: /kaggle/input/datasets/ipythonx/mvtec-ad

# 1. 레포 클론 + 설치
# git clone https://github.com/hq-deng/RD4AD.git
# pip install timm

# 2. 코드 수정 (pandas 호환 + 경로 수정)
# sed -i "s|'./mvtec/'|'/kaggle/input/datasets/ipythonx/mvtec-ad/'|g" main.py
# sed -i "s|item_list = \['carpet'.*|item_list = ['hazelnut']|" main.py
# sed -i '118d' main.py
# sed -i '1s/^/import pandas as pd\n/' test.py
# sed -i 's/df = df.append(\(.*\), ignore_index=True)/df = pd.concat([df, pd.DataFrame([\1])], ignore_index=True)/g' test.py

# 3. 실행
# mkdir -p checkpoints
# python main.py \
#     --data_path /kaggle/input/datasets/ipythonx/mvtec-ad \
#     --category hazelnut \
#     --epochs 200
