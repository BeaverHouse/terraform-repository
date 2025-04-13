# Git 브랜치 정리 스크립트
Write-Host "Fetching and pruning remote branches..." -ForegroundColor Green
git remote update origin --prune
git config --global advice.forceDeleteBranch false

# 로컬 브랜치와 리모트 브랜치 정보 가져오기
$localBranches = git branch --format="%(refname:short)" | Out-String
$remoteBranches = git branch -r | Out-String

# 각 로컬 브랜치 확인
$localBranches.Split("`n") | ForEach-Object {
    $branch = $_.Trim()
    if ($branch) {
        $remoteBranch = "origin/$branch"
        if (-not ($remoteBranches -match [regex]::Escape($remoteBranch))) {
            git branch -D $branch
            Write-Host "Deleted local branch: $branch" -ForegroundColor Yellow
        }
        else {
            Write-Host "Local branch $branch exists in remote" -ForegroundColor Cyan
        }
    }
}