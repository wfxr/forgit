#!/bin/bash

set -e

tag_has_public_changes=false

previous_tag=$(git describe --tags --abbrev=0 HEAD~)

# Enable case-insensitive matching
shopt -s nocasematch

# Loop through all commits since previous tag
for rev in $(git log "$previous_tag"..HEAD --format="%H" --reverse --no-merges); do
    summary=$(git log "$rev"~.."$rev" --format="%s")
    # Exclude commits starting with "Meta"
    if [[ $summary != Meta* ]]; then
        tag_has_public_changes=true
        break
    fi
done

head_tag=$(git describe --exact-match 2>/dev/null || true)

git log --color=always --format="%C(auto)%h %s%d" | head

if ! $tag_has_public_changes; then
    echo "No public changes since $previous_tag." >&2
    exit 1
elif [[ ${head_tag} =~ [\d{2}\.\d{2}\.\d+] ]]; then
    echo "Version tag ${head_tag} already exists."
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
