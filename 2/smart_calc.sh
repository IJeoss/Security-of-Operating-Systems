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
            if ((number == 0)); then
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