cargo test --test 2>&1 | grep "    " | awk '{$1=$1};1'

