while IFS= read -r line; do
    #bin не должно быть частью другого
    if grep -qw 'bin' <<< "$line"; then
        printf '%s\n' "$line" >&2
    fi
done