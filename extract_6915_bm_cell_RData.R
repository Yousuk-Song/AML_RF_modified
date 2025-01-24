#!/usr/bin/env Rscript

# 필요한 라이브러리
library(dplyr)

# 디렉토리 및 파일 설정
backspin_file <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/BM_6915cells.BackSPIN.txt"
rdata_dir <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/RData"
output_file <- "/mnt/S1/data/rawdata/scRSEQ_AML/aml2019_RF/BM_6915cell.RData"

# RData 파일 목록 가져오기
rdata_files <- list.files(rdata_dir, pattern = "BM.*\\.star.expr.RData$", full.names = TRUE)
rdata_files

# BackSPIN 파일에서 cell ID 읽기
backspin_data <- read.delim(backspin_file, header = TRUE, sep = "\t")
cell_ids <- backspin_data$cell
cell_ids <- gsub("-", ".", cell_ids)
cell_ids
length(cell_ids)

# 최종 데이터를 저장할 리스트
filtered_cells_list <- list()
filtered_stats_list <- list()

# RData 파일 처리
total_filtered_cells <- 0  # 총 필터링된 셀 수

for (rdata_file in rdata_files) {
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
    filtered_cells <- d[, colnames(d) %in% cell_ids, drop = FALSE]
    filtered_stats <- d.stats[colnames(d) %in% cell_ids, , drop = FALSE]
  } else if (exists("D") && exists("D.stats")) {
    filtered_cells <- D[, colnames(D) %in% cell_ids, drop = FALSE]
    filtered_stats <- D.stats[colnames(D) %in% cell_ids, , drop = FALSE]
  } else {
    stop(paste("No matching data (D, D.stats, or d, d.stats) found in", rdata_file))
  }
  
  # 필터링된 데이터를 리스트에 추가
  filtered_cells_list[[basename(rdata_file)]] <- filtered_cells
  filtered_stats_list[[basename(rdata_file)]] <- filtered_stats
  
  # 총 필터링된 셀 수 업데이트
  num_filtered_cells <- ncol(filtered_cells)
  total_filtered_cells <- total_filtered_cells + num_filtered_cells
  
  cat("Processed:", basename(rdata_file), "- Filtered cells:", num_filtered_cells, "\n")
}

# 모든 데이터를 합쳐서 하나의 객체로 저장
names(filtered_cells_list) <- NULL
E <- do.call(cbind, filtered_cells_list)
E.stats <- do.call(rbind, filtered_stats_list)

# 결과 저장
save(E, E.stats, file = output_file)

# Total filtered cell 합계 출력
cat("Total filtered cells across all samples:", total_filtered_cells, "\n")
cat("Final combined data saved to:", output_file, "\n")
