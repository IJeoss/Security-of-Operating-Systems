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