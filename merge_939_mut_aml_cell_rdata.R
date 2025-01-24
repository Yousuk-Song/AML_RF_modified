#!/usr/bin/env Rscript

# 필요한 라이브러리
library(dplyr)

# 디렉토리 설정
rdata_dir <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/RData"
filtered_dir <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/matrix/mut_cell_id"
output_file <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/AMLmut_939cells.RData"

# 파일 목록 가져오기
rdata_files <- list.files(rdata_dir, pattern = "AML.*\\.RData$", full.names = TRUE)
filtered_files <- list.files(filtered_dir, pattern = "*filtered_cellid_muttranscripts.txt$", full.names = TRUE)

# 샘플 이름에서 공통 부분 추출 (예: AML1012-D0, AML210A-D0 등)
rdata_samples <- gsub("^[^_]*_", "", gsub("\\.star\\.expr\\.RData$", "", basename(rdata_files)))
filtered_samples <- gsub("^[^_]*_", "", gsub("_filtered_cellid_muttranscripts\\.txt$", "", basename(filtered_files)))

# 매칭된 샘플 찾기
matched_samples <- intersect(rdata_samples, filtered_samples)

# 매칭된 파일 경로 추출
matched_rdata_files <- rdata_files[rdata_samples %in% matched_samples]
matched_filtered_files <- filtered_files[filtered_samples %in% matched_samples]

# 최종 데이터를 저장할 리스트
filtered_cells_list <- list()
filtered_stats_list <- list()

# Total filtered cells 개수를 계산하기 위한 변수
total_filtered_cells <- 0

# RData와 필터링된 파일 매칭 및 처리
for (sample in matched_samples) {
  # 매칭된 파일 경로
  rdata_file <- matched_rdata_files[grep(sample, matched_rdata_files)]
  filtered_file <- matched_filtered_files[grep(sample, matched_filtered_files)]
  
  # 필터링된 파일에서 Cell ID 읽기
  filtered_data <- read.delim(filtered_file, header = TRUE, sep = "\t")
  filtered_cell_ids <- filtered_data$Cell  # 첫 번째 열이 Cell ID
  
  # Cell ID 형식 통일 (필요한 경우)
  # "AML1012-D0_AAAA..." -> "AAAA..."
  filtered_cell_ids <- gsub("-", ".", filtered_cell_ids)
  
  # 기존 변수 제거
  if (exists("D")) rm(D)
  if (exists("D.stats")) rm(D.stats)
  if (exists("d")) rm(d)
  if (exists("d.stats")) rm(d.stats)
  
  # RData 파일 로드
  loaded_objects <- load(rdata_file)
  print(paste("Loaded objects from", rdata_file, ":", paste(loaded_objects, collapse = ", ")))
  
  # Cell ID를 기준으로 필터링
  if (exists("d") && exists("d.stats")) {
    filtered_cells <- d[, colnames(d) %in% filtered_cell_ids, drop = FALSE]
    filtered_stats <- d.stats[colnames(d) %in% filtered_cell_ids, , drop = FALSE]
  } else if (exists("D") && exists("D.stats")) {
    filtered_cells <- D[, colnames(D) %in% filtered_cell_ids, drop = FALSE]
    filtered_stats <- D.stats[colnames(D) %in% filtered_cell_ids, , drop = FALSE]
  } else {
    stop(paste("No matching data (D, D.stats, or d, d.stats) found in", rdata_file))
  }
  
  # 필터링된 데이터를 리스트에 추가
  filtered_cells_list[[sample]] <- filtered_cells
  filtered_stats_list[[sample]] <- filtered_stats
  
  # 총 필터링된 셀 수 업데이트
  num_filtered_cells <- ncol(filtered_cells)
  total_filtered_cells <- total_filtered_cells + num_filtered_cells
  
  cat("Processed:", sample, "- Filtered cells:", num_filtered_cells, "\n")
}

# 모든 데이터를 합쳐서 하나의 객체로 저장
E <- do.call(cbind, filtered_cells_list)
E.stats <- do.call(rbind, filtered_stats_list)

# 결과 저장
save(E, E.stats, file = output_file)

# Total filtered cell 합계 출력
cat("Total filtered cells across all samples:", total_filtered_cells, "\n")
cat("Final combined data saved to:", output_file, "\n")
