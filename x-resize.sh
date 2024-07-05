#!/bin/bash

declare -A disps usrs
usrs=()
disps=()

for i in $(users);do
        [[ $i = root ]] && continue # skip root
        usrs[$i]=1
done

for u in "${!usrs[@]}"; do
        for i in $(sudo ps e -u "$u" | sed -rn 's/.* DISPLAY=(:[0-9]*).*/\1/p');do
                disps[$i]=$u
        done
done

for d in "${!disps[@]}";do
        session_user="${disps[$d]}"
        session_display="$d"
        session_output=$(sudo -u "$session_user" PATH=/usr/bin DISPLAY="$session_display" xrandr | awk '/ connected/{print $1; exit; }')
        sudo -u "$session_user" PATH=/usr/bin DISPLAY="$session_display" xrandr --output "$session_output" --auto | tee -a $LOG_FILE;
done
