#!/bin/bash

if (( $# != 1 )) || [[ ! -f "$1" ]]; then
    echo "Использование: $0 sales.csv" >&2
    exit 1
fi

set -o pipefail

LC_ALL=C awk -F, '
NR == 1 { next }

{
    total += $2
    count++

    if (count == 1 || $2 > max) {
        max = $2
        maxId = $1
    }
}

END {
    if (count == 0) {
        print "Нет данных о продажах" > "/dev/stderr"
        exit 1
    }

    printf "Общая сумма продаж: %.2f\n", total
    printf "Средняя стоимость: %.2f\n", total / count
    printf "Самая дорогая продажа: %s (%.2f)\n", maxId, max
}
' "$1" | tee sales_report.txt