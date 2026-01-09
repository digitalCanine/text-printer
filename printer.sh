#!/bin/bash

RAW_TEXT="${1:-DC}"
TOKEN="[ ${RAW_TEXT} ] "
TOKEN_LEN=${#TOKEN}

tput civis

clear
cleanup() {
  tput cnorm
  printf "\n\e[2mThe system stands, quietly\e[0m\n"
  exit 0
}
trap cleanup INT TERM

freq=0.06
i=0

while true; do
  cols=$(tput cols)

  # Compute smooth rainbow color ONCE per line
  read r g b <<<$(awk -v i="$i" -v f="$freq" 'BEGIN {
    r = int(127 * (sin(f*i) + 1))
    g = int(127 * (sin(f*i + 2.094) + 1))
    b = int(127 * (sin(f*i + 4.188) + 1))
    print r, g, b
  }')

  # Build a line that will never wrap
  line=""
  while ((${#line} + TOKEN_LEN < cols)); do
    line+="$TOKEN"
  done

  printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"

  ((i++))
  sleep 0.02
done
