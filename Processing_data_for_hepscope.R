# 1 필요한 패키지 로드
library(Seurat)
library(data.table)
setwd("/home/song7602/1.scripts/HepScope")
# 2 Seurat RDS 파일 로드
aml.test <- readRDS("/data/workbench/scRSEQ_AML/data/aml.cfinder2.rds")

# 3 정상(Normal)과 악성(Malignant) 라벨 정의
aml.test$Phenotype <- ifelse(aml.test$label == "1", "Malignant", "Normal")

# 라벨 확인
table(aml.test$Phenotype)

# 4 Normal(0), Malignant(1) 세포 분리
aml_normal <- subset(aml.test, Phenotype == "Normal")
aml_malignant <- subset(aml.test, Phenotype == "Malignant")

# 5 균형 맞추기 위해 Normal에서 subsampling
aml_normal <- subset(aml_normal, cells = sample(Cells(aml_normal), 3000))
dim(aml_normal)

# 6 Training/Validation/Test Split
set.seed(123)
aml_train_normal <- subset(aml_normal, cells = sample(Cells(aml_normal), 2000))
aml_val_normal <- subset(aml_normal, cells = setdiff(Cells(aml_normal), Cells(aml_train_normal)))
aml_test_normal <- subset(aml_val_normal, cells = sample(Cells(aml_val_normal), 1000))

aml_train_malig <- subset(aml_malignant, cells = sample(Cells(aml_malignant), 4000))
aml_val_malig <- subset(aml_malignant, cells = setdiff(Cells(aml_malignant), Cells(aml_train_malig)))
aml_test_malig <- subset(aml_val_malig, cells = sample(Cells(aml_val_malig), 1000))

# 7 유전자 리스트 불러오기 (cancer.up.txt에서 유전자 이름 가져오기)
gene_list <- fread("/home/song7602/1.scripts/HepScope/cancer.up.txt", header = FALSE)$V1

# 8 RNA 데이터 추출 (유전자 리스트 활용)
train_Normal <- GetAssayData(aml_train_normal[gene_list,], assay = "RNA", slot = "data")
train_Malig <- GetAssayData(aml_train_malig[gene_list,], assay = "RNA", slot = "data")

val_Normal <- GetAssayData(aml_val_normal[gene_list,], assay = "RNA", slot = "data")
val_Malig <- GetAssayData(aml_val_malig[gene_list,], assay = "RNA", slot = "data")

test_Normal <- GetAssayData(aml_test_normal[gene_list,], assay = "RNA", slot = "data")
test_Malig <- GetAssayData(aml_test_malig[gene_list,], assay = "RNA", slot = "data")

# 9 데이터 변환 (행=샘플, 열=유전자)
train_Normal <- as.data.frame(t(as.matrix(train_Normal)))
train_Malig <- as.data.frame(t(as.matrix(train_Malig)))
val_Normal <- as.data.frame(t(as.matrix(val_Normal)))
val_Malig <- as.data.frame(t(as.matrix(val_Malig)))
test_Normal <- as.data.frame(t(as.matrix(test_Normal)))
test_Malig <- as.data.frame(t(as.matrix(test_Malig)))

# 10 CSV 파일로 저장
write.table(train_Normal, "train_Normal.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
write.table(train_Malig, "train_Malig.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
write.table(val_Normal, "val_Normal.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
write.table(val_Malig, "val_Malig.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
write.table(test_Normal, "test_Normal.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
write.table(test_Malig, "test_Malig.csv", row.names = TRUE, col.names = FALSE, sep = ",", quote = FALSE)
