test day:
  zig build test_$(printf "%02d" {{day}}) --summary all
run day:
  zig build $(printf "%02d" {{day}})
