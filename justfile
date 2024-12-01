test day:
  zig test {{justfile_directory()}}/src/$(printf "%02d" {{day}}).zig 2>&1 | head

run day:
  zig run {{justfile_directory()}}/src/$(printf "%02d" {{day}}).zig
