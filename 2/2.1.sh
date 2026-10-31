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