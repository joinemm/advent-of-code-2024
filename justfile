currentDay := shell("date '+%d'")

[private]
default:
  just --list

test day=currentDay:
  zig build test_{{day}} --summary all

run day=currentDay:
  zig build {{day}}

benchmark day=currentDay:
  zig build install_{{day}} -Doptimize=ReleaseFast
  hyperfine zig-out/bin/{{day}} -N --export-markdown src/{{day}}/README.md

observe day=currentDay:
  zig build install_{{day}} -Doptimize=ReleaseFast
  poop zig-out/bin/{{day}}
