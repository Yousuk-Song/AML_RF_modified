jmchoi@C3:/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/matrix$ cat count_mut_and_build_filter_cell_id.sh 
#!/bin/bash

# 데이터 디렉토리 및 출력 디렉토리 설정
DIR="/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/matrix"
OUTPUT_DIR="$DIR/mut_cell_id"

# 출력 디렉토리가 없으면 생성
mkdir -p "$OUTPUT_DIR"

# .anno.txt.gz 파일 목록 가져오기
FILES=$(ls $DIR/*AML*anno.txt.gz)

# 결과를 저장할 배열
declare -a mut_counts

# 파일 처리 루프
i=0
total=0  # 총 합 초기화
for file in $FILES; do
  # 파일 이름과 출력 파일 경로 설정
  base_name=$(basename "$file" .anno.txt.gz)
  output_file="$OUTPUT_DIR/${base_name}_filtered_cellid_muttranscripts.txt"

  # "MutTranscripts" 열의 값을 동적으로 추출하고 필터링
  count=$(zcat "$file" | awk -F'\t' -v output="$output_file" '
    BEGIN { OFS = "\t" }
    NR == 1 {
      # 헤더에서 열 인덱스 찾기
      for (i = 1; i <= NF; i++) {
        if ($i == "Cell") cell_idx = i
        if ($i == "MutTranscripts") mut_idx = i
        if ($i == "WtTranscripts") wt_idx = i
      }
      # 필수 열이 없으면 종료
      if (!cell_idx || !mut_idx || !wt_idx) {
        exit 1
      }
      # 출력 파일에 헤더 저장
      print "Cell", "MutTranscripts", "WtTranscripts" > output
    }
    NR > 1 && $mut_idx ~ /\// {  # MutTranscripts에 "/" 포함된 행만 필터링
      print $cell_idx, $mut_idx, $wt_idx > output
      mut[$mut_idx]++
    }
    END {
      for (m in mut) sum += mut[m]
      print sum
    }
  ')

  # 필터링된 결과 저장
  if [[ -z $count ]]; then
    count=0
  fi
  mut_counts[i]=$count
  echo "File: $(basename $file), MutTranscripts Count: $count"

  # 총합 계산
  total=$((total + count))
  ((i++))
done

# 전체 결과 출력
echo "MutTranscripts counts: ${mut_counts[@]}"
echo "Total MutTranscripts Count: $total"  # 총 합 출력
