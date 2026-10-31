#!/bin/bash

format=text
generate_sql=false

while getopts ':f:g' opt; do
    case $opt in
        f) format=$OPTARG ;;
        g) generate_sql=true ;;
        :) echo "Для -$OPTARG требуется значение" >&2; exit 1 ;;
        \?) echo "Неизвестная опция: -$OPTARG" >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if (( $# != 1 )) || [[ ! -f $1 ]]; then
    echo "Использование: $0 [-f csv] [-g] sales.csv" >&2
    exit 1
fi

if [[ $format != text && $format != csv ]]; then
    echo "Поддерживается только формат csv" >&2
    exit 1
fi

if [[ $generate_sql == true ]]; then
    format=csv
fi

if [[ $format == csv ]]; then
    report_file=sales_report.csv
else
    report_file=sales_report.txt
fi

set -o pipefail

LC_ALL=C awk -F, -v format="$format" '
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

    if (format == "csv") {
        print "metric,value,sale_id"
        printf "total,%.2f,\n", total
        printf "average,%.2f,\n", total / count
        printf "maximum,%.2f,%s\n", max, maxId
    } else {
        printf "Общая сумма продаж: %.2f\n", total
        printf "Средняя стоимость: %.2f\n", total / count
        printf "Самая дорогая продажа: %s (%.2f)\n", maxId, max
    }
}
' "$1" | tee "$report_file" || exit 1

if [[ $generate_sql == true ]]; then
    {
        cat <<'SQL'
CREATE TABLE IF NOT EXISTS sales_report (
    metric TEXT PRIMARY KEY,
    value NUMERIC(18,2) NOT NULL,
    sale_id INTEGER
);

TRUNCATE TABLE sales_report;

COPY sales_report (metric, value, sale_id)
FROM STDIN WITH (FORMAT csv, HEADER true);
SQL
        cat sales_report.csv
        printf '\\.\n'
    } > import_sales.sql

    echo "SQL-файл: import_sales.sql" >&2
fi