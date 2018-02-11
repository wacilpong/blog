#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

if [ "$(git status -s)" ]; then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

# Remove previous published contents.
rm -rf public
mkdir public

# Also remove public git worktree
git worktree prune
rm -rf .git/worktree/public

# making worktree and link to gh-pages
git worktree add -B gh-pages public origin/gh-page
rm -rf public/*

# Build the project. if you set submodule, run git submodule init for the first.
hugo -t minimal

# Go To Public folder.
cd public

# Add changes to git.
git add -all

# Commit changes.
msg="publishing to gh-pages `date`"
git commit -m "$msg"

# Push source and build repos.
git push origin gh-pages

# Back to master
cd ..