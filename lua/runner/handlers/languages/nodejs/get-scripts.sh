npm run 2>&1 | grep "  " | awk '{$1=$1};1' | sed -n 'p;n'

