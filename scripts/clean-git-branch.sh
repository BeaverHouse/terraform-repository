# Fetch the origin branch
git remote update origin --prune
git config --global advice.forceDeleteBranch false

# Delete all local branches that are only exist in the local
LOCAL_BRANCHES=$(git branch --format="%(refname:short)")
REMOTE_BRANCHES=$(git branch --merged)

for branch in $LOCAL_BRANCHES; do
    if ! echo "$REMOTE_BRANCHES" | grep -q "\b$branch\b"; then
        git branch -D "$branch"
        echo "Deleted local branch: $branch"
    else
        echo "Local branch $branch is exist in remote"
    fi
done
