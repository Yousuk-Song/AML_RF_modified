import pandas as pd
import glob
import os
import re

# 현재 디렉토리에서 .anno.txt.gz 파일 찾기
file_pattern = "*AML*.anno.txt.gz"
files = glob.glob(file_pattern)

# 각 파일에 대해 'DN'이 포함된 MutTranscripts 값의 Cell ID 추출 및 저장
for file_path in files:
    try:
        # gzip으로 압축된 파일을 직접 열기
        data = pd.read_csv(file_path, sep='\s+', compression='gzip', engine='python', on_bad_lines='skip')

        print(f"\nProcessing file: {file_path}")
        print("Total number of rows in the file:", len(data))

        # 'MutTranscripts' 열이 있는지 확인 후 필터링
        if 'MutTranscripts' in data.columns:
            filtered_data = data[
                data['MutTranscripts'].str.contains('/') & data['WtTranscripts'].str.contains('normal')
            ][['Cell', 'MutTranscripts', 'WtTranscripts']]


            # 필터링된 데이터가 제대로 생성되었는지 확인
            print("\nFiltered Data (first 5 rows):")
            print(filtered_data.head())  # 필터링된 데이터의 첫 5개 행을 출력하여 확인

            # 저장 직전 데이터 확인
            print("\nData to be saved:")
            print(filtered_data)

            # 파일명 생성
            file_name = file_path.replace('.anno.txt.gz', '_filtered_cellid_muttranscripts.txt')

            # 파일에 쓰기 전에 데이터가 비어 있지 않은지 확인
            if not filtered_data.empty:
                # 필터링된 cell ID와 MutTranscripts 값을 파일로 저장 (header=True로 변경)
                filtered_data.to_csv(file_name, index=False, header=False, sep='\t')
                print(f"Filtered cell IDs and MutTranscripts saved to: {file_name}")
            else:
                print(f"No data to save for file: {file_path}")
        else:
            print("'MutTranscripts' column not found in the data.")
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
os.system('./check_cell_numb.sh')
