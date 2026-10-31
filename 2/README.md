# Лабораторная работа БОС № 2

## 2 Задания

### 2.1

> **Разработать сценарий, который ведёт в файле `/tmp/run.log` последовательный журнал запусков: в конец журнала добавляет строку с датой и временем запуска сценария (командой `date`); в стандартный вывод (`stdout`) выводит фразу «Hello, World!»; в стандартный вывод ошибок (`stderr`) выводит количество предыдущих запусков программы.**

**Файл:** `2.1.sh`

```bash
#!/usr/bin/env bash

log_file=/tmp/run.log

#считаем запуски ДО добавления новой
if [[ -f "$log_file" ]]; then
    prev=$(wc -l < "$log_file")
else
    prev=0
fi

date >> "$log_file"
printf 'Hello, World!\n'
printf 'Кол-во предыдущих запусков: %s\n' "$prev" >&2
```

### 2.2

> **Разработать сценарий, который запускает сценарий, разработанный в предыдущем задании, а также открывает журнал запусков предыдущего сценария в программе `less`.**

**Файл:** `2_2.sh`

```bash
#!/usr/bin/env bash

bash "2.1.sh"
less /tmp/run.log
```

### 2.3

> **Разработать сценарий, который считывает построчно стандартный ввод и выводит только те строки, которые содержат слово `bin` целиком, в стандартный вывод ошибок.**

**Файл:** `2.3.sh`

```bash
#!/usr/bin/env bash

while IFS= read -r line || [[ -n "$line" ]]; do
    #bin не должно быть частью другого
    if grep -qw 'bin' <<< "$line"; then
        printf '%s\n' "$line" >&2
    fi
done
```

или проще

```bash
#!/usr/bin/env bash
grep -w 'bin' >&2
```

### 2.4

> **Разработать сценарий, который для всех файлов с расширением `txt` в домашнем каталоге пользователя выведет список таких файлов и их суммарный размер в байтах и строках.**

**Файл:** `2.4.sh`

```bash
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
```

### 2.5

> **Разработать сценарий поиска дубликатов файлов (файлов с одинаковым содержимым), который выводит сначала количество дубликатов, затем имя файла. Файлы без дубликатов выводиться не должны.**

**Файл:** `2.5.sh`

```bash
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
```

число перед именем означает, сколько **других** файлов имеют такое же содержимое

### 2.6

> **Разработать сценарий, который выводит на экран количество переданных ему аргументов.**

**Файл:** `2.6.sh`

```bash
#!/usr/bin/env bash

printf 'Количество аргументов: %s\n' "$#"
```

### 2.7

> **Написать скрипт `filter_numbers.sh`, который принимает список чисел как аргументы (`$@`), перебирает числа, пропускает делящиеся на 3, записывает чётные в `even.txt`, нечётные — в `odd.txt`, а в конце сообщает количество обработанных чисел.**

**Файл:** `filter_numbers.sh`

```bash
#!/bin/bash

#затираем файлы перед перезаписью
: > even.txt
: > odd.txt

count=0
for num in "$@"; do
    if ((num%3==0)); then
        continue
    fi

    if ((num%2==0)); then
        echo "$num" >> even.txt
    else
        echo "$num" >> odd.txt
    fi

    ((count+=1))
done

echo "Обработано чисел: $count"
echo "Общее число переданных: $#"
```
### 2.8

> **Изучить обработку опций через `getopt`/`getopts`. Написать скрипт `smart_calc.sh` с опциями `-h` (справка), `-v` (подробный вывод), `-o <file>` (файл вывода), который обрабатывает оставшиеся аргументы как числа, выполняет сложение, умножение, вычитание, возведение в степень или деление в зависимости от опции и выводит результат.**

**Файл:** `smart_calc.sh`

```bash
#!/bin/bash

operation=add
verbose=false
output_file=

while getopts ':hvo:amspd' opt; do
    case $opt in
        h) echo "Использование: $0 [-h] [-v] [-o файл] [-a|-m|-s|-p|-d] число1 число2 ..."; exit 0 ;;
        v) verbose=true ;;
        o) output_file=$OPTARG ;;
        a) operation=add ;;
        m) operation=mul ;;
        s) operation=sub ;;
        p) operation=pow ;;
        d) operation=div ;;
        :) echo "Для -$OPTARG требуется значение" >&2; exit 1 ;;
        \?) echo "Неизвестная опция: -$OPTARG" >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if (($#<2)); then
    echo "Нужно передать минимум два целых числа" >&2
    exit 1
fi

for number in "$@"; do
    if [[ ! $number =~ ^-?(0|[1-9][0-9]*)$ ]]; then
        echo "Некорректное число: $number" >&2
        exit 1
    fi
done

count=$#
result=$1
shift

for number in "$@"; do
    case $operation in
        add) ((result += number)) ;;
        mul) ((result *= number)) ;;
        sub) ((result -= number)) ;;
        pow)
            if ((number < 0)); then
                echo "Отрицательная степень не поддерживается" >&2
                exit 1
            fi
            result=$((result ** number)) ;;
        div)
            if ((number==0)); then
                echo "Деление на ноль" >&2
                exit 1
            fi
            ((result /= number)) ;;
    esac
done

if [[ $verbose == true ]]; then
    echo "Операция: $operation, чисел: $count" >&2
fi

if [[ -n $output_file ]]; then
    echo "$result" > "$output_file"
else
    echo "$result"
fi

```

### 2.9

> **Подготовить тестовые данные и написать скрипт `analyze_sales.sh`, принимающий имя CSV-файла с данными о продажах, выводящий общую сумму продаж, среднюю стоимость продажи и самую дорогую продажу. Сохранить результаты в `sales_report.txt` с помощью `tee`.**

**Файл:** `analyze_sales_2_9.sh`

```bash
#!/bin/bash

if (( $# != 1 )) || [[ ! -f "$1" ]]; then
    echo "Использование: $0 sales.csv" >&2
    exit 1
fi

set -o pipefail

LC_ALL=C awk -F, '
NR == 1 { next }

{
    total+=$2
    count++

    if (count==1 || $2>max){
        max=$2
        maxId=$1
    }
}

END {
    if (count==0){
        print "Нет данных о продажах" > "/dev/stderr"
        exit 1
    }

    printf "Общая сумма продаж: %.2f\n", total
    printf "Средняя стоимость: %.2f\n", total / count
    printf "Самая дорогая продажа: %s (%.2f)\n", maxId, max
}
' "$1" | tee sales_report.txt
```


### 2.10

> **Модифицировать скрипт из предыдущего задания: по опции `-f csv` представлять данные `sales_report` в CSV-формате; по опции `-g` генерировать SQL-запросы для импорта данных из `sales_report.csv` в таблицу PostgreSQL.**

**Файл:** `analyze_sales.sh`

```bash
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
NR==1 {next}

{
    total += $2
    count++

    if (count==1 || $2>max){
        max=$2
        maxId=$1
    }
}

END {
    if (count==0){
        print "Нет данных о продажах" > "/dev/stderr"
        exit 1
    }

    if (format == "csv"){
        print "metric,value,sale_id"
        printf "total,%.2f,\n", total
        printf "average,%.2f,\n", total / count
        printf "maximum,%.2f,%s\n", max, maxId
    }else{
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
```