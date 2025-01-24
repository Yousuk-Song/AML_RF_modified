#!/bin/bash

# 데이터 디렉토리 설정
DIR="/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/matrix"

# .anno.txt.gz 파일 목록 가져오기
FILES=$(ls $DIR/*AML*anno.txt.gz)

# 결과를 저장할 배열
declare -a mut_counts

# 파일 처리 루프
i=0
for file in $FILES; do
  # "MutTranscripts" 열의 값을 추출하고 빈도를 합산
  count=$(zcat "$file" | awk -F'\t' 'NR > 1 && $9 != "" {mut[$9]++} END {for (m in mut) sum += mut[m]; print sum}')
  mut_counts[i]=$count
  echo "File: $(basename $file), MutTranscripts Count: $count"
  ((i++))
done

# 전체 결과 출력
echo "MutTranscripts counts: ${mut_counts[@]}"
