currentDay := shell("date '+%d'")

[private]
default:
  @just --list

test day=currentDay:
  zig build test_{{day}} --summary all

run part day=currentDay:
  zig build {{day}}_{{part}}

benchmark day=currentDay:
  zig build install_{{day}}_1 -Doptimize=ReleaseFast
  zig build install_{{day}}_2 -Doptimize=ReleaseFast
  hyperfine zig-out/bin/{{day}}_1 zig-out/bin/{{day}}_2 -N --warmup 1 --export-markdown src/{{day}}/README.md

graph day=currentDay:
  ./graph.sh {{day}}
