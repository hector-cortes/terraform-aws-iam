#!/bin/bash

# 
git_rebase_in_progress() {
    [[ -d "$(git rev-parse --git-path rebase-merge)" || -d "$(git rev-parse --git-path rebase-apply)" ]]
}

current_branch=$(git rev-parse --abbrev-ref HEAD)
first_branch_commit=$(git log main..$current_branch --format=format:%H | tail -1)
GIT_SEQUENCE_EDITOR="sed -i -re 's/^pick /e /'" git rebase -i $first_branch_commit

while git_rebase_in_progress
do
    echo "Run fmt, rebase"
    edited_files=$(terraform fmt -recursive)
    git add $edited_files
    git commit --amend --no-edit
    GIT_EDITOR=true git rebase --continue
done