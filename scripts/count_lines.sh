#!/bin/bash

# Terraform 파일의 라인 수를 계산하는 스크립트
total_lines=0
file_count=0

echo -e "\033[32mCalculating Terraform file line count...\033[0m"

# 모든 .tf 파일을 재귀적으로 찾아서 처리
while IFS= read -r -d '' file; do
    lines=$(wc -l < "$file")
    total_lines=$((total_lines + lines))
    file_count=$((file_count + 1))
    
    # 각 파일의 정보 출력
    echo -e "\033[33m$file: $lines lines\033[0m"
done < <(find . -name "*.tf" -print0)

# 최종 결과 출력
echo -e "\n\033[32mFinal result\033[0m"
echo -e "\033[36mTotal file count: $file_count\033[0m"
echo -e "\033[36mTotal line count: $total_lines\033[0m" 