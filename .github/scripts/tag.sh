#!/bin/bash

set -e

head_tag=$(git describe --exact-match 2>/dev/null || true)

git log --color=always --format="%C(auto)%h %s%d" | head

if [[ ${head_tag} =~ [\d{2}\.\d{2}\.\d+] ]]
then
    echo "Current master already has version tag ${head_tag}"
else
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    version=$(date +'%y.%m.0')
    git tag -a ${version} -m "Release ${version}"
    git push origin ${version}
    git log --color=always --format="%C(auto)%h %s%d" | head -1
    echo "Pushed new tag:"
    echo "${REPO_URL}/releases/tag/${version}"
fi
