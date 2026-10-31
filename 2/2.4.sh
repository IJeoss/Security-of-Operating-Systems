#!/bin/bash

linesCount=0
bytesCount=0

for file in "$HOME"/*.txt; do
    [[ -f "$file" ]] || continue

    echo "$file"

    curLines=$(wc -l < "$file")
    curBytes=$(wc -c < "$file")

    linesCount=$((linesCount + curLines))
    ((bytesCount+=curBytes))
done

echo "Всего строк: $linesCount"
echo "Всего байт: $bytesCount"