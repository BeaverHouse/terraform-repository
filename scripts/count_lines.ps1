# Terraform 파일의 라인 수를 계산하는 스크립트
$totalLines = 0
$fileCount = 0

Write-Host "Calculating Terraform file line count..." -ForegroundColor Green

# 모든 .tf 파일을 재귀적으로 찾아서 처리
Get-ChildItem -Path . -Filter *.tf -Recurse | ForEach-Object {
    $lines = (Get-Content $_.FullName -Encoding UTF8).Count
    $totalLines += $lines
    $fileCount++
    
    # 각 파일의 정보 출력
    Write-Host "$($_.FullName): $lines lines" -ForegroundColor Yellow
}

# 최종 결과 출력
Write-Host "`nFinal result" -ForegroundColor Green
Write-Host "Total file count: $fileCount" -ForegroundColor Cyan
Write-Host "Total line count: $totalLines" -ForegroundColor Cyan 