#!/bin/bash

release_has_public_changes=false

url=$(git remote get-url origin | sed -r 's/(.*)\.git/\1/')

previous_tag=$(git describe --tags --abbrev=0 HEAD~)

echo "Changes since $previous_tag:"
echo

# Loop through all commits since previous tag
for rev in $(git log $previous_tag..HEAD --format="%H" --reverse --no-merges)
do
    summary=$(git log $rev~..$rev --format="%s")
    # Exclude commits starting with "Meta"
    if [[ $summary != Meta* ]]
    then
        # Print markdown list of commit headlines
        echo "* [$summary]($url/commit/$rev)"
        # Append commit body indented (blank lines and signoff trailer removed)
        git log $rev~..$rev --format="%b" | sed '/^\s*$/d' | sed '/^Signed-off-by:/d' | \
        while read -r line
        do
            # Escape markdown formatting symbols _ * `
            echo "  $line" | sed 's/_/\\_/g' | sed 's/`/\\`/g' | sed 's/\*/\\\*/g'
        done
        release_has_public_changes=true
    fi
done

if ! $release_has_public_changes
then
    echo "No public changes since $previous_tag." >&2
    exit 1
fi
