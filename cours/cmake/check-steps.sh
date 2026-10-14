#!/usr/bin/env bash
# Rebuild each CMake step in a temporary folder and check that it compiles,
# passes its tests and runs. Used by the CI, can be run by hand:
#   bash cours/cmake/check-steps.sh
#
# Step N = the sources of the project (root folder)
#        + the files of the steps 01 to N copied on top (as the students do).
# Step 4 is the root folder itself: it is checked by the main CI job.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
steps="$root/cours/cmake"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for step in "$steps"/0*/; do
    name="$(basename "$step")"
    echo "===== $name"
    rm -rf "$work/project"
    mkdir "$work/project"
    cp -r "$root"/{cmake,include,src,apps,tests} "$work/project"
    for previous in "$steps"/0*/; do
        cp -r "$previous". "$work/project"
        [ "$previous" = "$step" ] && break
    done
    cmake -S "$work/project" -B "$work/build" -DCMAKE_BUILD_TYPE=Release > /dev/null
    cmake --build "$work/build" --config Release > /dev/null
    if [ -f "$work/build/CTestTestfile.cmake" ]; then
        ctest --test-dir "$work/build" -C Release --output-on-failure
    fi
    find "$work/build" -name greet -type f -perm -u+x -exec {} Alice \;
    rm -rf "$work/build"
done
