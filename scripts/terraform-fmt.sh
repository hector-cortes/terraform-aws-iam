#!/bin/bash
#
# Edits each commit made in the current branch by running Terraform fmt
git_rebase_in_progress() {
    [[ -d "$(git rev-parse --git-path rebase-merge)" || -d "$(git rev-parse --git-path rebase-apply)" ]]
}

# Runs git rebase -i, starting from the first commit made on the active branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
first_branch_commit=$(git log main.."$current_branch" --format=format:%H | tail -1)
GIT_SEQUENCE_EDITOR="sed -i -re 's/^pick /e /'" git rebase -i "$first_branch_commit"

# Runs terraform fmt on each commit in the current branch
while git_rebase_in_progress
do
    edited_files=$(terraform fmt -recursive)
    git add "$edited_files"
    git commit --amend --no-edit
    GIT_EDITOR=true git rebase --continue
done
