#!/bin/bash

mapfile -d '' files < <(find . -type f -print0)

for file in "${files[@]}"; do
    count=0

    for other in "${files[@]}"; do
        if [[ "$file" == "$other" ]]; then
            continue
        fi

        if cmp -s "$file" "$other"; then
            ((count += 1))
        fi
    done

    if ((count > 0)); then
         echo "$count $file"
    fi
done