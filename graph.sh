#!/usr/bin/env bash

days="$(seq -w 01 "$1")"

for i in $days; do
    zig build install_"${i}" -Doptimize=ReleaseFast
done

# shellcheck disable=SC2046
hyperfine $(echo "$days" | xargs -I{} echo "zig-out/bin/{}") -N --warmup 1 --export-csv bench.csv

echo '```zig' >README.md

tail -n+2 bench.csv |
    awk -F, 'BEGIN { OFS="," } { gsub("zig-out/bin/", "Day ", $1); $2 = sprintf("%.2f", $2 * 1000); print $0 }' |
    uplot bar -d, --xscale log --width 75 --xlabel "Mean runtime in ms [log]" -o >>README.md

echo '```' >>README.md

rm bench.csv
