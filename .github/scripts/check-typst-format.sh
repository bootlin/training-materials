#!/bin/sh
# Verify every .typ source file in the repository is formatted according to
# typstyle's default style. Used by the typst-format GitHub workflow but can
# also be run locally from the repository root (requires typstyle on PATH).

set -u

typstyle --version

offenders=$(
    find slides common typst -name "*.typ" -type f -print0 \
        | xargs -0 -n1 -P 8 sh -c '
            typstyle --check "$1" >/dev/null 2>&1 || printf "%s\n" "$1"
          ' _
)

if [ -n "$offenders" ]; then
    echo
    echo "ERROR: the following typst files are not properly formatted:"
    printf '%s\n' "$offenders" | sort | sed 's/^/  - /'
    echo
    echo "Run 'typstyle -i \$(git diff --diff-filter=ACMR --name-only pubgit/master.. -- '*.typ')' locally to fix them."
    exit 1
fi

echo "All typst files are properly formatted."
