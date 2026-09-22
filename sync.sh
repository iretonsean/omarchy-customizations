#!/bin/bash

# Copy the current versions of the tracked files from $HOME back into files/.
# Run this after you change the setup, then commit.
#
# This only updates files that are already in files/. To track a new file,
# copy it into files/ at the same path it has under $HOME.
#
# Your projects stay out of the repo: they live in ~/.config/omarchy/projects.json,
# and the sections that projects-apply generates from it are emptied here.

set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$REPO/files"

while IFS= read -r -d '' file; do
  source="$HOME/${file#./}"
  if [[ -f $source ]]; then
    cp "$source" "$file"
  else
    echo "Missing on this machine, kept the repo copy: ${file#./}" >&2
  fi
done < <(find . -type f -print0)

python3 - <<'PY'
import re

files = {
    ".config/omarchy/extensions/omarchy-menu.jsonc": ("// ", ""),
    ".local/share/workspace-guide/index.html": ("<!-- ", " -->"),
}
for path, (open_, close) in files.items():
    with open(path) as handle:
        text = handle.read()
    pattern = re.compile(
        rf"^([ \t]*){re.escape(open_)}BEGIN projects-apply: ([\w-]+){re.escape(close)}\n.*?^([ \t]*){re.escape(open_)}END projects-apply: \2{re.escape(close)}",
        re.M | re.S,
    )
    text = pattern.sub(lambda m: f"{m.group(1)}{open_}BEGIN projects-apply: {m.group(2)}{close}\n{m.group(3)}{open_}END projects-apply: {m.group(2)}{close}", text)
    with open(path, "w") as handle:
        handle.write(text)
PY

git -C "$REPO" status --short
