#!/usr/bin/env bash
set -euo pipefail

# Reports standards whose supporting skill changed upstream since the standard
# was last aligned with it. Reads `aligned-with` stamps from the given files
# (default: this skill's standard templates). Requires an authenticated `gh`.
#
# Exit status: 0 when every standard is aligned, 1 when any drifted.

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$#" -eq 0 ]; then
  set -- "$SKILL_DIR"/templates/standards/*.md
fi

drift=0
for file in "$@"; do
  stamp="$(grep -m1 -o '<!-- aligned-with: [^>]*-->' "$file" || true)"
  [ -n "$stamp" ] || continue
  read -r _ _ source path aligned _ <<<"$stamp"
  latest="$(gh api "repos/$source/commits?path=$path&per_page=1" --jq '.[0].sha')"
  if [ "$latest" = "$aligned" ]; then
    echo "aligned  $file ($source/$path)"
  else
    drift=1
    echo "drifted  $file ($source/$path)"
    echo "         changes: https://github.com/$source/compare/${aligned:0:12}...${latest:0:12}"
    echo "         files:   $(gh api "repos/$source/compare/$aligned...$latest" --jq "[.files[].filename | select(startswith(\"$path/\"))] | join(\", \")")"
    echo "         latest:  $latest"
  fi
done
exit "$drift"
